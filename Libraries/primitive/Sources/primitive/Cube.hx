package primitive;

import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class Cube extends Shape {

	//!TODO : clean this code. work in progress.
	public function new(x : Int = 1,y : Int = 1,z : Int = 1) {

		super();

		var v:Array<Float> = new Array();
		var ind:Array<Int> = new Array();

		var w = x / 2;
		var h = y / 2;
		var d = z / 2;

		// Use indices :)

		v = [
			// Front face
			-w,-h, d,
			-w, h, d,
			 w,-h, d,
			 w, h, d,
			-w, h, d,
			 w,-h, d,

			// Back face
			-w,-h,-d,
			-w, h,-d,
			 w,-h,-d,
			 w, h,-d,
			-w, h,-d,
			 w,-h,-d,

			// Left face
			-w,-h, d,
			-w, h, d,
			-w,-h,-d,
			-w,-h,-d,
			-w, h,-d,
			-w, h, d,

			// Right face
			 w,-h, d,
			 w, h, d,
			 w,-h,-d,
			 w,-h,-d,
			 w, h,-d,
			 w, h, d,

			// Top face
			-w, h, d,
			 w, h, d,
			-w, h,-d,
			 w, h, d,
			 w, h,-d,
			-w, h,-d,

			// Bottom face
			-w,-h, d,
			 w,-h, d,
			-w,-h,-d,
			 w,-h, d,
			 w,-h,-d,
			-w,-h,-d,
		];
		
		 ind = [for (i in 0...Std.int(v.length / 3)) i];

		var structure : VertexStructure = getVertexStructure();

		vertexBuffer = new VertexBuffer(
			Std.int(v.length / 3), // 3 floats per vertex
			structure, 
			Usage.StaticUsage 
		);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, v[i]);
		}
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(
			ind.length, 
			Usage.StaticUsage 
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = ind[i];
		}
		indexBuffer.unlock();
	}
}