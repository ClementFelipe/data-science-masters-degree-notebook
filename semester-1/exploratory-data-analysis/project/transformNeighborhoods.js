const unwind = require("javascript-unwind")

const getCoords = (geometry) => {
  if (geometry.type === "Polygon") {
    return geometry.coordinates[0].map((c) => ({ i: c[0], j: c[1] }))
  } else {
    return geometry.coordinates.map((poly, i) => ({
      idx: i,
      coordinates: poly[0].map((c) => ({ i: c[0], j: c[1] }))
    }))
  }
};

const mapped = neighborhoods.features.map((currentObject) => ({
  name: currentObject.properties.Name,
  type: f.geometry.type,
  coordinates: getCoords(f.geometry)
}));

const unwindNeighborhood = (neighborhood) => unwind(neighborhood, 'coordinates').map((c) => ({
  name: `${c.name}_${c.coordinates.idx}`,
  coordinates: c.coordinates.coordinates
}));

const unwoundNeighborhoods = mapped.reduce((neighborhoods, neighborhood) => {
  if (neighborhood.type === 'MultiPolygon') {
    return [...neighborhoods, ...unwindNeighborhood(neighborhood)];
  } else {
    return [...neighborhoods, neighborhood];
  }
}, []);

const unwoundCoordinates = unwoundNeighborhoods.reduce((coordinates, neighborhood, i) => {
  return [
    ...coordinates,
    ...unwind(neighborhood, 'coordinates').map((neighborhood, innerIndex) => ({
      name: neighborhood.name,
      group: i,
      order: innerIndex,
      lat: neighborhood.coordinates.i,
      long: neighborhood.coordinates.j
    }))
  ]
}, []);

const textOutput = unwoundCoordinates.reduce((text, currentObject) => text + Object.values(currentObject).join(",") + "\n", "");

console.log(textOutput);
