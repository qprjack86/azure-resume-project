module.exports = async function (context, req, inputDoc) {
  const current = inputDoc && typeof inputDoc.count === 'number' ? inputDoc.count : 0;
  const count = current + 1;

  context.bindings.outputDoc = {
    id: '1',
    count
  };

  context.res = {
    status: 200,
    body: { count }
  };
};
