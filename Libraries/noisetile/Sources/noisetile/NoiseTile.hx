package noisetile;

import noisetile.Tiles;

class NoiseTile {

	public var t : Tiles;
	public function new(x : Int= 10,y : Int = 10, hw: Int = 16) {
			
		t = new Tiles(x,y,hw);
		
	}

	public function getNoiseTiles() {
			
		return t.getNoiseTiles();
		
	}

	public static function getHeight(x,y) {
			
		return Tiles.getHeight(x,y);
		
	}
}