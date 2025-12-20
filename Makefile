default:
	@zig run container.zig -freference-trace=11 -- mount=./moutdir/ uid=0 debug=true command='ls -alh'
ns:
	zig run -I . namespace2.zig -lc -D_GNU_SOURCE

ns3:
	zig run -I . namespace3.zig -lc -D_GNU_SOURCE

ns4:
	zig run namespace4.zig
