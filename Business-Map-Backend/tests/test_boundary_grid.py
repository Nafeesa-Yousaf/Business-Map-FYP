"""BoundaryService 3x3 strategic grid."""
from shapely.geometry import Point, Polygon

from app.services.shared.boundary import BoundaryService


def test_generate_grid_returns_nine_points_inside_bbox():
    svc = BoundaryService()
    poly = Point(73.05, 33.70).buffer(0.02)
    grid = svc.generate_grid_from_polygon(poly)
    assert len(grid) == 9
    min_lng, min_lat, max_lng, max_lat = poly.bounds
    for lat, lng in grid:
        assert min_lat <= lat <= max_lat
        assert min_lng <= lng <= max_lng


def test_generate_grid_centers_are_distinct():
    svc = BoundaryService()
    poly = Polygon([(0, 0), (0, 3), (3, 3), (3, 0)])
    grid = svc.generate_grid_from_polygon(poly)
    assert len(set(grid)) == 9


def test_is_point_in_town():
    svc = BoundaryService()
    poly = Point(73.05, 33.70).buffer(0.01)
    assert svc.is_point_in_town(33.70, 73.05, poly) is True
    assert svc.is_point_in_town(34.0, 74.0, poly) is False


def test_boundary_radius_clamped():
    svc = BoundaryService()
    tiny = Point(73.05, 33.70).buffer(0.0001)
    assert svc.get_boundary_radius(tiny) >= 1000
    huge = Point(73.05, 33.70).buffer(1.0)
    assert svc.get_boundary_radius(huge) <= 5000
