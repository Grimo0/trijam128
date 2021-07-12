package en;

class Ball extends Entity {
	public static final HIT_TIME_TO_REACT = .3 * Const.FPS;
	public static final HIT_TIME_BOUNCE = 5. * Const.FPS;

	public var timeBounce(default, null) : Float;
	var bouncePressedFrame : Int;
	var bounceCurve : h2d.Graphics;

	var timerTxt : h2d.Text;

	public function new() {
		super();

		spr.set(Assets.entities, 'BallSpr');

		wid = spr.tile.width;
		hei = spr.tile.height;

		frictX = .95;
		frictY = .85;
		gravity = 1;
		
		timeBounce = 0.;
		bouncePressedFrame = 0;
		
		bounceCurve = new h2d.Graphics();
		bounceCurve.alpha = .5;
		bounceCurve.visible = false;		
		level.root.add(bounceCurve, Const.GAME_LEVEL_TOP);

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

		// Bounce
		if (!game.ca.bDown())
			bouncePressedFrame = 0;
		else
			bouncePressedFrame++;

		if (canBounce()) {
			final curveControlXMul = .35;
			final curveControlYMul = -.6;
			final curveEndXMul = 1.;
			
 			if (bouncePressedFrame > 0 && bouncePressedFrame < 5 && game.ca.bDown()) {
				bouncePressedFrame = 0; // To ensure we don't pass the max frame

				if (timeBounce == 0) {
					bounceStart();
					bounceCurve.visible = true;
				}
				
				timeBounce += utmod;

				// Draw the curve
				var ballX = attachX;
				var ballY = attachY;

				bounceCurve.clear();
				
				// Max curve
				bounceCurve.lineStyle(1 / Const.GRID, 0xff3333, .5);
				bounceCurve.moveTo(ballX, ballY);
				bounceCurve.curveTo(
					ballX + curveControlXMul * Ball.HIT_TIME_BOUNCE, ballY + curveControlYMul * Ball.HIT_TIME_BOUNCE, 
					ballX + curveEndXMul * Ball.HIT_TIME_BOUNCE, ballY);

				// Current curve
				bounceCurve.lineStyle(1 / Const.GRID, 0x333333);
				bounceCurve.moveTo(ballX, ballY);
				bounceCurve.curveTo(
					ballX + curveControlXMul * timeBounce, ballY + curveControlYMul * timeBounce, 
					ballX + curveEndXMul * timeBounce, ballY);
			} else if (timeBounce > 0) {
				stopBounceTimer();
				bounceCurve.visible = false;

				// Give the ball the impulsion
				dx = 10 * curveControlXMul * timeBounce / Ball.HIT_TIME_BOUNCE;
				dy = 10 * curveControlYMul * timeBounce / Ball.HIT_TIME_BOUNCE;
				
				timeBounce = 0;
			}
		}

		// Ground hit and friction
		var groundFrict = 0.;
		if (hitOnBottom) {
			groundFrict = .15;
			
			if (!ucd.has('hitObstacle') && !game.locked && timeBounce == 0) {
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