import { readFileSync } from 'node:fs'
const text = readFileSync(new URL('../arabic-rtl.client.js', import.meta.url), 'utf8')
export default {
  apply(root) {
    root.on('webserver/index-inject', (rows) => {
      rows.push({ kind: 'script', placement: 'body', text })
    })
  },
}
