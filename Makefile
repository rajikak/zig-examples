default:
	@zig run container.zig -freference-trace=11 -- mount=./moutdir/ uid=0 debug=true command='ls -alh'
ns:
	zig run -I . namespace2.zig -lc -D_GNU_SOURCE
