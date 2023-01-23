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





    // our model's colored geometry
    var cubeVertexes:Array<Float> = [
        // near face
        -100.0, -100.0, 100.0, 100.0, 0.0, 0.0, 0.0, 0.0,
        -100.0, 100.0, 100.0, 100.0, 0.0, 0.0,  0.0, 100.0,
        100.0, 100.0, 100.0, 100.0, 0.0, 0.0,   100.0, 100.0,
        100.0, -100.0, 100.0, 100.0, 0.0, 0.0,  100.0, 0.0,

        // left face
        -100.0, -100.0, -100.0, 0.0, 100.0, 0.0, 0.0, 0.0,
        -100.0, 100.0, -100.0, 0.0, 100.0, 0.0,  0.0, 100.0,
        -100.0, 100.0, 100.0, 0.0, 100.0, 0.0,   100.0, 100.0,
        -100.0, -100.0, 100.0, 0.0, 100.0, 0.0,  100.0, 0.0,

        // far face
        100.0, -100.0, -100.0, 0.0, 0.0, 100.0,  0.0, 0.0,
        100.0, 100.0, -100.0, 0.0, 0.0, 100.0,   0.0, 100.0,
        -100.0, 100.0, -100.0, 0.0, 0.0, 100.0,  100.0, 100.0,
        -100.0, -100.0, -100.0, 0.0, 0.0, 100.0, 100.0, 0.0,

        // right face
        100.0, -100.0, 100.0, 100.0, 100.0, 0.0,  0.0, 0.0,
        100.0, 100.0, 100.0, 100.0, 100.0, 0.0,   0.0, 100.0,
        100.0, 100.0, -100.0, 100.0, 100.0, 0.0,  100.0, 100.0,
        100.0, -100.0, -100.0, 100.0, 100.0, 0.0, 100.0, 0.0,

        // top face
        -100.0, 100.0, 100.0, 100.0, 0.0, 100.0,  0.0, 0.0,
        -100.0, 100.0, -100.0, 100.0, 0.0, 100.0, 0.0, 100.0,
        100.0, 100.0, -100.0, 100.0, 0.0, 100.0,  100.0, 100.0,
        100.0, 100.0, 100.0, 100.0, 0.0, 100.0,   100.0, 0.0,

        // bottom face
        -100.0, -100.0, -100.0, 0.0, 100.0, 100.0, 0.0, 0.0,
        -100.0, -100.0, 100.0, 0.0, 100.0, 100.0,  0.0, 100.0,
        100.0, -100.0, 100.0, 0.0, 100.0, 100.0,   100.0, 100.0,
        100.0, -100.0, -100.0, 0.0, 100.0, 100.0,  100.0, 0.0
    ];

    // model's indexes
    var cubeIndexes:Array<UInt> = [
        0, 1, 2,
        0, 2, 3,
        4, 5, 6,
        4, 6, 7,
        8, 9, 10,
        8, 10, 11,
        12, 13, 14,
        12, 14, 15,
        16, 17, 18,
        16, 18, 19,
        20, 21, 22,
        20, 22, 23
    ];




		var structure : VertexStructure = getVertexStructure();

		vertexBuffer = new VertexBuffer(
			Std.int(cubeVertexes.length / 3), // 3 floats per vertex
			structure, 
			Usage.StaticUsage 
		);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, cubeVertexes[i]);
		}
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer(
			ind.length, 
			Usage.StaticUsage 
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...cubeIndexes.length) {
			iData[i] = cubeIndexes[i];
		}
		indexBuffer.unlock();
	}
}