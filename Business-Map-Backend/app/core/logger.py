import logging
import sys

from app.core.request_context import get_correlation_id

LOG_FORMAT = "%(levelname)-8s | %(name)s | %(correlation_id)s | %(message)s"


class CorrelationIdFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        record.correlation_id = get_correlation_id() or "-"
        return True


def setup_logging():
    root = logging.getLogger()
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter(LOG_FORMAT))
    handler.addFilter(CorrelationIdFilter())

    logging.basicConfig(
        level=logging.INFO,
        handlers=[handler],
        force=True,
    )
    # Ensure our filter is on any handlers basicConfig attached
    for h in root.handlers:
        h.addFilter(CorrelationIdFilter())
        if not isinstance(h.formatter, logging.Formatter) or "%(correlation_id)s" not in (
            h.formatter._fmt or ""
        ):
            h.setFormatter(logging.Formatter(LOG_FORMAT))


def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
