import fs from 'fs';

async function testUpload() {
  fs.writeFileSync('test.jpg', 'dummy data');
  const fileData = fs.readFileSync('test.jpg');
  const blob = new Blob([fileData]);
  const form = new FormData();
  form.append('file', blob, 'test.jpg');

  try {
    const res = await fetch('http://localhost:3333/api/upload/image', {
      method: 'POST',
      body: form
    });
    const text = await res.text();
    console.log('Status:', res.status);
    console.log('Response:', text);
  } catch (err) {
    console.error('Error:', err.message);
  }
}

testUpload();
