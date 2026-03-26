/*
 * static/js/lines-map-utils.js
 * Shared helpers for ordering trap coordinates before drawing line polylines.
 */

function getDistanceSquared(pointA, pointB) {
  const latDiff = pointA[0] - pointB[0];
  const lngDiff = pointA[1] - pointB[1];
  return (latDiff * latDiff) + (lngDiff * lngDiff);
}

function getRouteStartIndex(points) {
  let startIndex = 0;

  for (let index = 1; index < points.length; index += 1) {
    const currentPoint = points[index];
    const startPoint = points[startIndex];

    if (
      currentPoint[1] < startPoint[1] ||
      (currentPoint[1] === startPoint[1] && currentPoint[0] < startPoint[0])
    ) {
      startIndex = index;
    }
  }

  return startIndex;
}

function orderPointsByNearestNeighbor(points) {
  if (points.length < 3) return points.slice();

  const remainingPoints = points.slice();
  const orderedPoints = [];
  let currentPoint = remainingPoints.splice(getRouteStartIndex(remainingPoints), 1)[0];

  orderedPoints.push(currentPoint);

  while (remainingPoints.length > 0) {
    let nearestIndex = 0;
    let nearestDistance = getDistanceSquared(currentPoint, remainingPoints[0]);

    for (let index = 1; index < remainingPoints.length; index += 1) {
      const candidateDistance = getDistanceSquared(currentPoint, remainingPoints[index]);

      if (candidateDistance < nearestDistance) {
        nearestDistance = candidateDistance;
        nearestIndex = index;
      }
    }

    currentPoint = remainingPoints.splice(nearestIndex, 1)[0];
    orderedPoints.push(currentPoint);
  }

  return orderedPoints;
}