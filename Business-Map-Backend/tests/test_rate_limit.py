"""Rate-limit IP resolution must not trust leftmost X-Forwarded-For."""
from app.core.config import settings
from app.middleware.rate_limit import RateLimitMiddleware


def test_client_ip_ignores_xff_when_proxy_untrusted():
    mw = RateLimitMiddleware(app=None)
    setattr(settings, "TRUST_PROXY_HEADERS", False)

    class _Req:
        headers = {"x-forwarded-for": "1.2.3.4, 9.9.9.9"}
        client = type("C", (), {"host": "10.0.0.5"})()

    assert mw._client_ip(_Req()) == "10.0.0.5"


def test_client_ip_uses_rightmost_xff_when_proxy_trusted():
    mw = RateLimitMiddleware(app=None)
    setattr(settings, "TRUST_PROXY_HEADERS", True)

    class _Req:
        headers = {"x-forwarded-for": "spoofed-left, 203.0.113.10"}
        client = type("C", (), {"host": "10.0.0.5"})()

    assert mw._client_ip(_Req()) == "203.0.113.10"
