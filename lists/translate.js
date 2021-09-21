function translate(collection, key) {
  const translation = collection[Object.keys(collection)
    .find(k => k.toLowerCase() === key.toLowerCase())
  ];
  return translation ? translation : key;
}

exports.translate = translate;
