package en;

class Player extends Entity {
	var id : String;

	public var hasBall(default, set) : Bool;
	public function set_hasBall(b) {
		if (b) {
			spr.setFrame(0);
		} else {
			spr.setFrame(spr.group.anim.length - 1);			
		}
		return hasBall = b;
	}

	public function new(id : String) {
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
		});
	}
}