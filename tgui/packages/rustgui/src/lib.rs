use wasm_bindgen::prelude::*;

#[wasm_bindgen(start)]
fn start() {
    // executed automatically ...
}

#[wasm_bindgen]
pub fn add(left: u64, right: u64) -> u64 {
    left + right
}
