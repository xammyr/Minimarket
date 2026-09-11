const fs = require('fs');
const path = require('path');

function walk(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    file = path.join(dir, file);
    const stat = fs.statSync(file);
    if (stat && stat.isDirectory()) { 
      results = results.concat(walk(file));
    } else { 
      if (file.endsWith('.ts')) results.push(file);
    }
  });
  return results;
}

const files = walk('./src');
files.forEach(file => {
  const buffer = fs.readFileSync(file);
  // Check for UTF-16LE BOM
  if (buffer.length >= 2 && buffer[0] === 0xFF && buffer[1] === 0xFE) {
    console.log(`Fixing ${file}`);
    const content = buffer.toString('utf16le');
    fs.writeFileSync(file, content, 'utf8');
  } else if (buffer.length >= 2 && buffer[0] === 0x00 && buffer[1] === 0x00) {
      // Just in case it's something weird
  } else {
      // It might be ANSI but mostly it's UTF-16LE BOM from powershell.
      // If it doesn't have BOM but it's UTF16 LE?
      // Let's just try to read it as string. If it contains null bytes, it's UTF16.
      if (buffer.indexOf(0x00) !== -1) {
          console.log(`Fixing no-BOM UTF16 ${file}`);
          const content = buffer.toString('utf16le');
          fs.writeFileSync(file, content, 'utf8');
      }
  }
});
console.log('Done');
