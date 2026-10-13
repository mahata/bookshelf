// 新書判コミック用モジュール本棚（Bambu Lab A1 mini 向け）
//
// 1マスを同じ形のハーフシェル2個で作り、片方を上下反転して重ねる。
// 印刷用の部品は half_shell と test_coupon の2つ。
// STL の出力例: openscad -D 'part="half_shell"' -o half_shell.stl bookshelf.scad

/* [出力する部品] */
// half_shell と test_coupon が印刷用。ほかは確認用のプレビュー
part = "assembly"; // [half_shell, test_coupon, cell, assembly, exploded]

/* [配置（プレビューと部品表）] */
// 横に並べるマスの数
cols = 3; // [1:1:8]
// 縦に積むマスの数
rows = 2; // [1:1:6]
// ダミーの本を表示する
show_books = true;
// ダミーの本1冊の厚さ
book_t = 15.5;

/* [本のサイズ] */
// 本の高さ（新書判コミックは174mm）
book_h = 174;
// 本の奥行き（新書判コミックは112mm）
book_d = 112;
// 本の上に確保する余裕
clear_h = 16;
// 本の奥行きに対する余裕
clear_d = 8;

/* [部品の寸法] */
// マスの外形の幅
outer_w = 170;
// 側壁の厚さ
wall_t = 4;
// 背板の厚さ
back_t = 4;
// 床の厚さ
floor_t = 4;
// 稜線の面取り（継ぎ目にV溝ができる）
chamfer = 0.5;

/* [ダボ（1.75mmフィラメントを切って使う）] */
// ダボ穴の直径（test_coupon で合わせる）
pin_d = 2.0;
// 上下ハーフの継ぎ目のダボ穴の深さ
seam_pin_depth = 8;
// マス同士をつなぐダボ穴の深さ
link_pin_depth = 3;

/* [プリンター] */
// 造形範囲の一辺（A1 mini は180mm）
bed_size = 180;
// 造形範囲の縁に残す余裕
bed_margin = 5;

/* [Hidden] */
$fn = 32;
eps = 0.01;
filament_d = 1.75;
hole_chamfer = 0.4;
min_skin = 0.8;
face_skin = 0.4;
seam_pin_inset = 15;
stack_pin_inset = 30;
side_pin_inset = 25;
coupon_pin_ds = [1.9, 2.0, 2.1, 2.2];

inner_w = outer_w - 2 * wall_t;
inner_d = book_d + clear_d;
inner_h = book_h + clear_h;
outer_d = inner_d + back_t;
half_h = floor_t + inner_h / 2;
cell_h = 2 * half_h;
max_part = bed_size - bed_margin;
books_per_cell = floor(inner_w / book_t);

seam_pin_len = 2 * seam_pin_depth - 1;
link_pin_len = 2 * link_pin_depth - 1;

// 継ぎ目のダボ穴: 壁の上端面上の [x, y]
seam_pins = concat(
  [for (x = [wall_t / 2, outer_w - wall_t / 2],
        y = [seam_pin_inset, outer_d - seam_pin_inset]) [x, y]],
  [for (x = [outer_w / 4, outer_w * 3 / 4]) [x, outer_d - back_t / 2]]
);
// 縦積み用のダボ穴: 床の下面上の [x, y]
stack_pins = [for (x = [stack_pin_inset, outer_w - stack_pin_inset],
                   y = [stack_pin_inset, outer_d - stack_pin_inset]) [x, y]];
// 横並び用のダボ穴: 左右の側壁の外面上の [y, z]
side_pins = [for (y = [side_pin_inset, outer_d - side_pin_inset])
               [y, floor_t + (half_h - floor_t) / 2]];

function fmt1(v) = let(t = round(v * 10)) str(floor(t / 10), ".", t % 10);
function has_point(list, p) = min([for (q = list) norm(q - p)]) < 0.001;
function mirror_x(list) = [for (p = list) [outer_w - p[0], p[1]]];
function symmetric_x(list) =
  len([for (p = mirror_x(list)) if (!has_point(list, p)) p]) == 0;

assert(max(outer_w, outer_d, half_h) <= max_part,
  str("ハーフシェル ", [outer_w, outer_d, half_h], " が造形範囲 ", max_part, "mm を超えています"));
assert(inner_w > book_t, "マスの内幅が本1冊より狭くなっています");
// 継ぎ目の面は両側の面取りの分だけ壁より細い
assert(pin_d + 2 * max(min_skin, chamfer + face_skin) <= min(wall_t, back_t),
  "壁が薄く、継ぎ目のダボ穴の周囲に肉が残りません");
assert(link_pin_depth + min_skin <= min(wall_t, floor_t),
  "連結用のダボ穴が深すぎ、反対側の面に抜けます");
assert(seam_pin_depth < half_h - floor_t, "継ぎ目のダボ穴が深すぎます");
assert(chamfer < min(wall_t, back_t, floor_t) / 2, "面取りが大きすぎます");
// 上ハーフは前後軸まわりの180°回転で x -> outer_w - x に写るため、
// 穴が左右対称に並んでいれば同じ部品同士で位置が一致する
assert(symmetric_x(seam_pins), "継ぎ目のダボ穴が左右対称ではありません");
assert(symmetric_x(stack_pins), "縦積み用のダボ穴が左右対称ではありません");

echo(str("ハーフシェル外形 ", [outer_w, outer_d, half_h],
  " mm / マス内寸 ", [inner_w, inner_d, inner_h],
  " mm / 1マス約 ", books_per_cell, " 冊"));
echo(str(cols, "列×", rows, "段: 外形 ", [cols * outer_w, outer_d, rows * cell_h],
  " mm / ハーフシェル ", 2 * cols * rows, " 個 / ダボ ",
  seam_pin_len, "mm×", len(seam_pins) * cols * rows, " 本、",
  link_pin_len, "mm×",
  len(stack_pins) * cols * (rows - 1) + 2 * len(side_pins) * rows * (cols - 1),
  " 本"));

module chamfered_box(size, c) {
  hull() {
    translate([c, c, 0]) cube([size[0] - 2 * c, size[1] - 2 * c, size[2]]);
    translate([0, c, c]) cube([size[0], size[1] - 2 * c, size[2] - 2 * c]);
    translate([c, 0, c]) cube([size[0] - 2 * c, size[1], size[2] - 2 * c]);
  }
}

// 面 (z = 0) から +z 方向に掘るダボ穴。lead は入口の面取りで、エレファントフットを逃がし差し込みやすくする
module pin_hole(depth, d = pin_d, lead = 0) {
  translate([0, 0, -eps]) {
    cylinder(d = d, h = depth + eps);
    if (lead > 0) cylinder(d1 = d + 2 * lead, d2 = d, h = lead + eps);
  }
}

module cavity() {
  c = chamfer;
  translate([wall_t, -eps, floor_t]) cube([inner_w, inner_d + eps, half_h]);
  // 前面開口の内側の縁
  hull() {
    translate([wall_t - c, -eps, floor_t - c])
      cube([inner_w + 2 * c, eps, half_h]);
    translate([wall_t, c - eps, floor_t]) cube([inner_w, eps, half_h]);
  }
  // 壁の上端の内側の縁
  hull() {
    translate([wall_t, -eps, half_h - c]) cube([inner_w, inner_d + eps, eps]);
    translate([wall_t - c, -eps, half_h])
      cube([inner_w + 2 * c, inner_d + c + eps, 1]);
  }
}

module half_shell() {
  difference() {
    chamfered_box([outer_w, outer_d, half_h], chamfer);
    cavity();
    for (p = seam_pins)
      translate([p[0], p[1], half_h]) mirror([0, 0, 1]) pin_hole(seam_pin_depth);
    for (p = stack_pins)
      translate([p[0], p[1], 0]) pin_hole(link_pin_depth, lead = hole_chamfer);
    for (p = side_pins) {
      translate([0, p[0], p[1]]) rotate([0, 90, 0])
        pin_hole(link_pin_depth, lead = hole_chamfer);
      translate([outer_w, p[0], p[1]]) rotate([0, -90, 0])
        pin_hole(link_pin_depth, lead = hole_chamfer);
    }
  }
}

// 床と壁の角を切り出した小片。3方向のダボ穴を直径違いで並べる
module test_coupon() {
  pitch = 12;
  len_x = pitch * len(coupon_pin_ds) + 2;
  depth_y = 22;
  wall_h = 24;
  wall_y = depth_y - wall_t;
  difference() {
    union() {
      chamfered_box([len_x, depth_y, floor_t], chamfer);
      translate([0, wall_y, 0]) chamfered_box([len_x, wall_t, wall_h], chamfer);
    }
    for (i = [0 : len(coupon_pin_ds) - 1]) {
      d = coupon_pin_ds[i];
      x = pitch / 2 + 1 + i * pitch;
      translate([x, wall_y + wall_t / 2, wall_h]) mirror([0, 0, 1])
        pin_hole(seam_pin_depth, d);
      translate([x, depth_y, floor_t + 4]) rotate([90, 0, 0])
        pin_hole(link_pin_depth, d, hole_chamfer);
      translate([x, 7, 0]) pin_hole(link_pin_depth, d, hole_chamfer);
      translate([x, 14, floor_t - 0.6])
        linear_extrude(1)
          text(fmt1(d), size = 3.5, font = "Liberation Sans:style=Bold",
               halign = "center", valign = "center");
    }
  }
}

module upper_half() {
  translate([outer_w, 0, cell_h]) rotate([0, 180, 0]) half_shell();
}

module dummy_books() {
  palette = ["SteelBlue", "IndianRed", "Goldenrod", "SeaGreen", "SlateGray"];
  margin = (inner_w - books_per_cell * book_t) / 2;
  for (i = [0 : books_per_cell - 1])
    color(palette[i % len(palette)])
      translate([wall_t + margin + i * book_t + 0.3, inner_d - book_d, floor_t])
        cube([book_t - 0.6, book_d, book_h]);
}

module cell() {
  color("BurlyWood") half_shell();
  color("Tan") upper_half();
}

module assembly() {
  for (c = [0 : cols - 1], r = [0 : rows - 1])
    translate([c * outer_w, 0, r * cell_h]) {
      cell();
      if (show_books) dummy_books();
    }
}

module filament_pin(len) {
  color("OrangeRed") cylinder(d = filament_d, h = len);
}

// 下ハーフにダボを差した状態で、上ハーフと隣のマスを離して描く
module exploded() {
  gap = 40;
  for (c = [0 : cols - 1], r = [0 : rows - 1])
    translate([c * (outer_w + gap), 0, r * (cell_h + 2 * gap)]) {
      color("BurlyWood") half_shell();
      translate([0, 0, gap]) color("Tan") upper_half();
      for (p = seam_pins)
        translate([p[0], p[1], half_h - seam_pin_depth + 0.5])
          filament_pin(seam_pin_len);
      if (r < rows - 1)
        for (p = stack_pins)
          translate([outer_w - p[0], p[1], gap + cell_h - link_pin_depth + 0.5])
            filament_pin(link_pin_len);
      if (c < cols - 1)
        for (p = side_pins, z = [p[1], cell_h - p[1]])
          translate([outer_w - link_pin_depth + 0.5, p[0], z + (z > half_h ? gap : 0)])
            rotate([0, 90, 0]) filament_pin(link_pin_len);
    }
}

if (part == "half_shell") color("BurlyWood") half_shell();
else if (part == "test_coupon") color("BurlyWood") test_coupon();
else if (part == "cell") cell();
else if (part == "assembly") assembly();
else if (part == "exploded") exploded();
else assert(false, str("不明な part です: ", part));
