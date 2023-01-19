package primitive;

import primitive.Shape;
import primitive.Plane;

class Primitive {

	var s : Shape;

	public function new(shapeName : String, params : Dynamic) {
		
		switch shapeName {
		    case 'plane': {
		    	s = new Plane(params.w,params.h,params.x,params.y);
		    }
		    case 'heightmap': {
		    	var heights = [];
		    	for (i in 0...params.w){
			    	heights = heights.concat(params.heights[i]);
		    	}
		    	s = new Plane(params.w,params.h,params.x,params.y,1,1,heights,params.idx,params.idy);
		    }
		    case 'cube': {
		    	s = new Cube(params.x,params.y,params.z);
		    }
		    default: s = new Shape();
		}
			
	}

	public function getIndexBuffer() {
		return s.getIndexBuffer();
	}

	public function getVertexBuffer() {
		return s.getVertexBuffer();
	}
	
	public function getVertexStructure() {
		return s.getVertexStructure();
    }
}