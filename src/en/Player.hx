package en;

class Player extends Entity {
	public var ball(get, never) : en.Ball; inline function get_ball() return game.level.ball;

	var id : Int;

	public var hasBall(default, set) : Bool;
	public function set_hasBall(b) {
		if (b) {
			ball.visible = false;
			spr.setFrame(0);
			if (id == 2)
				game.levelSucess();
		} else {
			spr.setFrame(spr.group.anim.length - 1);
		}
		return hasBall = b;
	}

	public function new(id : Int) {
		super();

		this.id = id;
		spr.set(Assets.entities, 'PlayerSpr$id');
		spr.anim.setGlobalSpeed(.5);

		wid = spr.tile.width;
		hei = spr.tile.height;
		pivotY = 1.;

		hasBall = false;
	}

	public function launchBall() {
		if (!hasBall) return;
		spr.anim.play('PlayerSpr$id').onEnd(() -> {
			hasBall = false;
			ball.visible = true;
			ball.setPosCell(cx + Std.int(wid * pivotX / Const.GRID), cy - Std.int(hei / Const.GRID));
			ball.dx = 2;
			ball.dy = -2;
		});
	}
}