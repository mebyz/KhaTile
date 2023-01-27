package noisetile;

import VectorMath.length;
import js.lib.Float32Array;
import noisetile.SimplexNoise;

@:expose
class Tiles {

	public var tiles : Array<Dynamic> = new Array();
	public var normals : Array<Dynamic> = new Array();
	//public static var TILES :Int = 80;
    //public static var HEIGHTMAPSIZE 	: Int = 16;  

    public function new(x : Int= 10,y : Int = 10, hw: Int = 16) {
        for ( i in 0...x ) {
            for (j in 0...y) {
            	 addTile(i,j,hw);
            }
    	}
    }

    public function getNoiseTiles() {
    	return tiles;
    }
    
	public function getNormalsTiles() {
    	return normals;
    }


	public function allocateHMap(width, depth){
		var heightMap : Array<Array<Array<Float>>>	= new Array();
		for(x in 0...width){
			heightMap[x] = new Array();
			for(z in 0...depth){
				heightMap[x][z] = new Array();
			}
		}
		return heightMap;
	}

	public function allocateNMap(width, depth){

		var nm : Array<Array<Float32Array>>	= new Array();
		for(x in 0...width){
			nm[x] = new Array();
			for(z in 0...depth){
				nm[x][z] = new Float32Array(width* depth *3);
			}
		}
		return nm;
		
	}

	public static function getNormal(x : Int,z : Int)  {
  
		var u:Float = getHeight(x,z-1);				
		var r:Float = getHeight(x+1,z);		
		var l:Float = getHeight(x-1,z);		
		var d:Float = getHeight(x,z+1);		
		
		var n: Vec3 = new Vec3(0,0,0);
		n.z = u - d;
		n.x = l - r;
		n.y = 2.0;
		return VectorMath.normalize(n);

	  }

	public static function getHeight(x : Int,z : Int) : Float{
		
		var simplex	= new SimplexNoise();
		var height:Float	= 0;
		var level	= 8;
		height	+= (simplex.noise((x)/level, (z)/level)/2 + 0.5) * 0.25;
		level	*= 3;
		height	+= (simplex.noise((x)/level, (z)/level)/2 + 0.5) * 0.7;
		level	*= 2;
		height	+= (simplex.noise((x)/level, (z)/level)/2 + 0.5) * 1;
		level	*= 2;
		height-=((Math.cos((x/2+50)/40)*2))+((Math.sin((z/2+110)/40)*2))+6;
		height	+= (simplex.noise((x)/level, (z)/level)/2 + 0.5) * 1.8;
		height	/= 1+0.5+0.25+0.125;
		height *=3.6;
		return height*500+1500;
	}

	public  function SHMap(heightMap: Dynamic, xx:Int, zz:Int){
		var width	= heightMap.length;
		var depth	= heightMap[0].length;

		for(x  in xx...(width+xx)){
			for(z in zz...(depth+zz)){

				var height : Float	= getHeight(x, z);

				heightMap[x-xx][z-zz] = height;
			}
		}
		return heightMap;
	}

	public  function SNMap(normalMap: Dynamic, xx:Int, zz:Int){
		var width	= normalMap.length;
		var depth	= normalMap[0].length;
var f = new Array<Float>();
		for(x  in xx...(width+xx)){
			for(z in zz...(depth+zz)){

				var normal: Vec3 = getNormal(x,z);

				//trace(i);
				//trace(normal);
				//trace(normal.x);

				f.push(normal.x);
				f.push(normal.y);
				f.push(normal.z);
				/*
				normalMap[x-xx][z-zz][i]=0.5+normal.x;
				normalMap[x-xx][z-zz][i+1]=0.5+normal.y;
				normalMap[x-xx][z-zz][i+2]=0.5+normal.z;
				*/
				//trace(normalMap[x-xx][z-zz][i]);
				//trace("===");
				
				//i = i+1;
			}
		}
		normalMap = Float32Array.from(f);
		//trace(normalMap);
		return normalMap;
	}

    public function addTile(x, y, hw) {

		var heightMap = allocateHMap(hw, hw);
		var normalMap = allocateNMap(hw, hw);
		
        heightMap = SHMap(heightMap, (hw - 1) * x, (hw - 1) * y);
		normalMap = SNMap(normalMap, (hw - 1) * x, (hw - 1) * y);


        tiles.push(heightMap);
		normals.push(normalMap);
     }
}

