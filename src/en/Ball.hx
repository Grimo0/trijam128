package en;

class Ball extends Entity {
	public static final HIT_TIME_TO_REACT = .3 * Const.FPS;
	public static final HIT_TIME_BOUNCE = 3. * Const.FPS;

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
		var startBoucing = false;
		if (!game.ca.bDown())
			bouncePressedFrame = 0;
		else
			bouncePressedFrame++;

		if (canBounce()) {
			final curveControlXMul = .35;
			final curveControlYMul = -.6;
			final curveEndXMul = 1.;
			
			var bounceX = .1 * curveControlXMul * timeBounce;
			var bounceY = .1 * curveControlYMul * timeBounce;
			
 			if (bouncePressedFrame > 0 && bouncePressedFrame < 5 && game.ca.bDown()) {
				bouncePressedFrame = 0; // To ensure we don't pass the max frame

				if (timeBounce == 0) {
					bounceStart();
					bounceCurve.visible = true;
				}
				
				timeBounce += utmod;

				// Draw the curve
				bounceCurve.clear();

				bounceCurve.beginFill(0xff3333);
				bounceCurve.drawRect(attachX - wid - 1, bottom, 2, -15);
				bounceCurve.beginFill(0x00a3ff);
				bounceCurve.drawRect(attachX - wid - 1, bottom, 2, -15 * timeBounce / HIT_TIME_BOUNCE);
				
				/* var currentX = attachX;
				var currentY = attachY;
				
				// Max curve
				bounceCurve.lineStyle(1 / Const.GRID, 0xff3333, .5);
				bounceCurve.moveTo(currentX, currentY);
				bounceCurve.curveTo(
					currentX + curveControlXMul * HIT_TIME_BOUNCE, currentY + curveControlYMul * HIT_TIME_BOUNCE, 
					currentX + curveEndXMul * HIT_TIME_BOUNCE, currentY);

				var endX = 0.;
				bounceX *= Const.GRID;
				while (M.fabs(bounceX) > 0.0005) {	
					endX += bounceX;
					bounceX *= frictX;
				}
				endX = endX + currentX;

				var endY = 0.;
				while (M.fabs(bounceY) > 0.0005) {	
					endY += bounceY + gravity;
					bounceY *= frictY;
				}
				endY = endY + currentY;

				// Current curve
				bounceCurve.lineStyle(1 / Const.GRID, 0x333333);
				bounceCurve.moveTo(currentX, currentY);
				bounceCurve.curveTo(
					currentX + curveControlXMul * timeBounce, currentY + curveControlYMul * timeBounce, 
					endX, currentY);
					
				bounceCurve.lineStyle(1 / Const.GRID, 0x00a3ff);
				bounceCurve.moveTo(endX, currentY);
				bounceCurve.drawCircle(endX, currentY, 2);
				bounceCurve.moveTo(endX, currentY - 2);
				bounceCurve.lineTo(endX, currentY - 10); */
			} else if (timeBounce > 0) {
				stopBounceTimer();
				bounceCurve.visible = false;
				startBoucing = true;
				timeBounce = 0;

				// Give the ball the impulsion
				dx = bounceX;
				dy = bounceY;
			}
		}

		// Ground hit and friction
		var groundFrict = 0.;
		if (hitOnBottom && !startBoucing) {
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

		if (timerTxt.visible) {
			var timeLeft = ucd.getS('hitObstacle');
			if (timeLeft < 2)
				timerTxt.color.setColor(0xffff3333);
			else
				timerTxt.color.setColor(0xffffffff);
			timerTxt.text = Std.string(Std.int(timeLeft * 10) / 10) + '\n"Space"';
		}
	}	
}