/* THE FOUR OLDS — render the assembled .fountain draft to PDF via Fountain.toPdf.
   Run: node src/FourOlds_Pdf.res.mjs <src.fountain> <out.pdf> */
@val @scope("process") external argv: array<string> = "argv"

let main = async () => {
  let src = Belt.Array.get(argv, 2)->Belt.Option.getWithDefault("")
  let out = Belt.Array.get(argv, 3)->Belt.Option.getWithDefault("")
  if src == "" || out == "" {
    Js.log("usage: node src/FourOlds_Pdf.res.mjs <src.fountain> <out.pdf>")
  } else {
    await Fountain.toPdf(~srcPath=src, ~outPath=out)
    Js.log("wrote " ++ out)
  }
}
main()->ignore
