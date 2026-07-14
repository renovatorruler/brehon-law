/* Shared casting map for trailer pulls (no runner main — safe to import).
   Same voices as the scene renderer. */
let voice = who =>
  switch who {
  | "CRICKET" => Some("sP6cqUGhZxuStGV0pn9o")
  | "DUTCH" => Some("TqOasn6BO225ydKxXhaK")
  | "STITCH" => Some("FPofnDi5DdNeTktLQ0u9")
  | "GUNNY" => Some("9oa4l5rZznK9dXRwFpSB")
  | "MARWANI" => Some("ZF7Ng6hYSXU5QiOXbbSZ")
  | "HALE" => Some("onwK4e9ZLuTAKqWW03F9")
  | "VESS" => Some("lVpo6IOLjDX4LxkYRZyj")
  | "BUCK" => Some("pqHfZKP75CvOlQylNhV4")
  | "RADIO" => Some("XrExE9yKIg1WjnnlVkGX")
  | "TITO" => Some("LxsCEphJBnRAyXU02gTG")
  | "BRANDT" => Some("JcwFVpR60FiOW4cPEqI2")
  | "DOCKWORKER" => Some("iP95p4xoKVk53GoZ742B")
  | "LAWYER #1" => Some("cjVigY5qzO86Huf0OWal")
  | "LAWYER #2" => Some("nPczCjzI2devNBz1zQrb")
  | _ => None
  }
