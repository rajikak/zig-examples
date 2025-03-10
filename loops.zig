test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }

    try expect(i == 128);
}

pub fn main() {
    var i: u8 = 2;
    while (i < 100) {

    }
}
