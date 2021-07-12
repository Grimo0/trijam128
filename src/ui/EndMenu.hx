package ui;

class EndMenu extends Modal {
	public function new(gameOver : Bool) {
		super();
		
		var txt = new h2d.Text(Assets.fontMedium, root);
		txt.setScale(1 / 12);
		txt.textAlign = Center;
		if (gameOver)
			txt.text = "Try again";
		else
			txt.text = "Well done !";
		txt.x = 26;
		txt.y = 10;
	}
}
