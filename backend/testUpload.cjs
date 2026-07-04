const fs = require('fs');
const FormData = require('form-data');
const axios = require('axios');

async function testUpload() {
  fs.writeFileSync('test.jpg', 'dummy data');
  const form = new FormData();
  form.append('file', fs.createReadStream('test.jpg'));

  try {
    const res = await axios.post('http://localhost:3333/api/upload/image', form, {
      headers: form.getHeaders(),
    });
    console.log('Success:', res.data);
  } catch (err) {
    console.error('Error:', err.response ? err.response.data : err.message);
  }
}

testUpload();
