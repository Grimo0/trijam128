package en;

class Player extends Entity {
	public function new(id : String) {
		super();

		spr.set(Assets.entities, 'PlayerSpr$id');

		wid = spr.tile.width;
		hei = spr.tile.height;
		pivotY = 1.;
	}
}