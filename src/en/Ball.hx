package en;

class Ball extends Entity {
	public static final HIT_TIME_TO_REACT = .3 * Const.FPS;
	public static final HIT_TIME_BOUNCE = 5. * Const.FPS;

	var timerTxt : h2d.Text;

	public function new() {
		super();

		spr.set(Assets.entities, 'BallSpr');

		wid = spr.tile.width;
		hei = spr.tile.height;

		frictX = .95;
		frictY = .85;
		gravity = 1;

		timerTxt = new h2d.Text(Assets.fontPixel, spr);
		timerTxt.setScale(.25);
		timerTxt.textAlign = Center;
		timerTxt.y = hei;
		timerTxt.visible = false;
	}

	public inline function canBounce() : Bool {
		return ucd.has('hitObstacle') && !game.locked;
	}

	public inline function startBounceTimer() {
		timerTxt.visible = true;
		ucd.setF('hitObstacle', HIT_TIME_TO_REACT, () -> {
			game.gameOver();
		});
		game.stopFrame(HIT_TIME_TO_REACT);
	}

	public inline function bounceStart() {
		var time = HIT_TIME_BOUNCE / Const.FPS - ucd.getInitialValueF('hitObstacle') / ucd.baseFps + ucd.getS('hitObstacle');
		ucd.setS('hitObstacle', time);
		game.stopFrame(time);
	}

	public inline function stopBounceTimer() {
		ucd.unset('hitObstacle');
		game.stopFrame(0.);
		timerTxt.visible = false;
	}

	override function update() {
		if (!visible) return;
		var groundFrict = 0.;
		if (hitOnBottom) {
			groundFrict = .15;
			
			if (!ucd.has('hitObstacle') && !game.locked && game.timeBounce == 0) {
				startBounceTimer();
			}
		}
		
		frictX -= groundFrict;
		super.update();
		frictX += groundFrict;
	}

	override function postUpdate() {
		super.postUpdate();

		if (cy > game.level.cHei || cx > game.level.cWid) {
			game.gameOver();
			destroy();
		}

		if (!game.level.player2.hasBall
			&& right > game.level.player2.left
			&& left < game.level.player2.right
			&& top < game.level.player2.bottom
			&& bottom > game.level.player2.top)
			game.level.player2.hasBall = true;

		if (timerTxt.visible)
			timerTxt.text = Std.string(Std.int(ucd.getS('hitObstacle') * 10) / 10);
	}	
}