/* ============================================================================
   Pdf — the one place HTML becomes a PDF file. Playwright, not Chrome's own
   CLI: --print-to-pdf hangs on this machine (a known, previously-diagnosed
   issue — a telemetry network call that never returns). Playwright's own
   bundled Chromium avoids it. Mirrors Cinema_Backends' binding style: real
   @module/@send externals, no escape hatches.
   ============================================================================ */

type browser
type page
type chromiumT

@module("playwright") external chromium: chromiumT = "chromium"
@send external launch: chromiumT => promise<browser> = "launch"
@send external newPage: browser => promise<page> = "newPage"
@send external closeBrowser: browser => promise<unit> = "close"

type contentOpts = {waitUntil: string}
@send external setContent: (page, string, contentOpts) => promise<unit> = "setContent"

type pdfOpts = {
  path: string,
  printBackground: bool,
  preferCSSPageSize: bool,
}
@send external pdfGen: (page, pdfOpts) => promise<unit> = "pdf"

/* Render an already-styled HTML document (its own @page CSS controls size/
   margins — preferCSSPageSize honors that instead of forcing US Letter) to a
   PDF at outPath. Launches and tears down its own browser per call; callers
   rendering many documents in one process should batch through one browser
   themselves rather than call this in a tight loop. */
let fromHtml = async (~html: string, ~outPath: string) => {
  let b = await launch(chromium)
  let p = await newPage(b)
  let _ = await setContent(p, html, {waitUntil: "networkidle"})
  let _ = await pdfGen(p, {path: outPath, printBackground: true, preferCSSPageSize: true})
  await closeBrowser(b)
}
