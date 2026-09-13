import { readFileSync, writeFileSync } from 'node:fs'
import { parseSync } from '@slidev/parser'

const filePath = process.argv[2] || 'slides.md'
const md = readFileSync(filePath, 'utf-8')
const lines = md.split('\n')
const data = parseSync(md, filePath)

const slidesToMigrate = []

data.slides.forEach(s => {
  const content = s.content || ''
  const linesInContent = content.split('\n')
  const firstNonEmpty = linesInContent.find(l => l.trim().length > 0)
  if (firstNonEmpty && firstNonEmpty.startsWith('# ')) {
    const headingText = firstNonEmpty.replace(/^#\s+/, '').trim()
    slidesToMigrate.push({
      slide: s,
      headingText
    })
  }
})

console.log(`Found ${slidesToMigrate.length} slides to migrate.`)

let migratedCount = 0

// Process backwards so line additions/deletions don't shift start/end line numbers of earlier slides
for (let i = slidesToMigrate.length - 1; i >= 0; i--) {
  const { slide: s, headingText } = slidesToMigrate[i]
  const slideLines = lines.slice(s.start, s.end)
  
  // Find frontmatter fences within this slide
  let fence1 = -1
  let fence2 = -1
  for (let j = 0; j < slideLines.length; j++) {
    if (slideLines[j].trim() === '---') {
      if (fence1 === -1) fence1 = j
      else if (fence2 === -1) { fence2 = j; break }
    }
  }
  
  if (fence1 !== -1 && fence2 !== -1) {
    let titleLineIdx = -1
    let layoutLineIdx = -1
    for (let j = fence1 + 1; j < fence2; j++) {
      if (/^title:\s*/.test(slideLines[j])) titleLineIdx = j
      if (/^layout:\s*/.test(slideLines[j])) layoutLineIdx = j
    }
    
    const escaped = headingText.replace(/"/g, '\\"')
    const needsQuotes = /[:&%#`*?[\]{}@]/.test(headingText)
    const formattedTitle = needsQuotes ? `title: "${escaped}"` : `title: ${headingText}`
    
    if (titleLineIdx !== -1) {
      slideLines[titleLineIdx] = formattedTitle
    } else if (layoutLineIdx !== -1) {
      slideLines.splice(layoutLineIdx + 1, 0, formattedTitle)
      fence2++
    } else {
      slideLines.splice(fence1 + 1, 0, formattedTitle)
      fence2++
    }
    
    // Find the # Heading line in body (after fence2)
    for (let j = fence2 + 1; j < slideLines.length; j++) {
      if (slideLines[j].trim().startsWith('# ')) {
        slideLines.splice(j, 1)
        if (j < slideLines.length && slideLines[j].trim() === '') {
          slideLines.splice(j, 1)
        }
        break
      }
    }
    
    lines.splice(s.start, s.end - s.start, ...slideLines)
    migratedCount++
  }
}

console.log(`Successfully migrated ${migratedCount} slides.`)
const result = lines.join('\n')
const outPath = process.argv[3] || 'slides.md'
writeFileSync(outPath, result, 'utf-8')
console.log(`Wrote migrated slides to ${outPath}`)
