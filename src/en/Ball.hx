package en;

class Ball extends Entity {
	public function new() {
		super();

		spr.set(Assets.entities, 'ballSpr');
		spr.color.set(0, .64, 1);

		wid = spr.tile.width;
		hei = spr.tile.height;
	}

	
}