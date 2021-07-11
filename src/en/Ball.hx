package en;

class Ball extends Entity {
	public function new() {
		super();

		spr.set(Assets.entities, 'BallSpr');

		wid = spr.tile.width;
		hei = spr.tile.height;
	}

	override function postUpdate() {
		super.postUpdate();

		if (cy > game.level.cHei || cx > game.level.cWid)
			game.gameOver();
	}	
}