import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const cases=JSON.parse(fs.readFileSync(path.join(root,'tests/cases.json'),'utf8'));
for (const fixture of cases) {
  const result=spawnSync(process.execPath,[path.join(root,'_build/js/debug/build/cmd/main/main.js'),'-'],{input:JSON.stringify(fixture.request),encoding:'utf8'});
  assert.equal(result.status,fixture.exit,fixture.name+': '+result.stderr);
  const report=JSON.parse(result.stdout);
  for (const [key,expected] of Object.entries(fixture.expected)) {
    let actual=report;for (const part of key.split('/'))actual=actual[part];
    assert.deepEqual(actual,expected,fixture.name+': '+key);
  }
}
console.log('CLI fixtures passed:',cases.length);
