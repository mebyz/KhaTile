package primitive;

import kha.SystemImpl;
import js.Syntax;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.graphics4.ConstantLocation;
import kha.Framebuffer;
import kha.math.FastMatrix4;
import kha.graphics4.CompareMode;
import kha.Shaders;
import kha.Assets;
import kha.Framebuffer;
import kha.Color;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;

class SkyCubeModel {
	
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;

	var mvp:FastMatrix4;
	var mvpID:ConstantLocation;


	// Array of colors for each cube vertex
	static var colors:Array<Float> = [
	    0.583,  0.771,  0.014,
		0.609,  0.115,  0.436,
		0.327,  0.483,  0.844,
		0.822,  0.569,  0.201,
		0.435,  0.602,  0.223,
		0.310,  0.747,  0.185,
		0.597,  0.770,  0.761,
		0.559,  0.436,  0.730,
		0.359,  0.583,  0.152,
		0.483,  0.596,  0.789,
		0.559,  0.861,  0.639,
		0.195,  0.548,  0.859,
		0.014,  0.184,  0.576,
		0.771,  0.328,  0.970,
		0.406,  0.615,  0.116,
		0.676,  0.977,  0.133,
		0.971,  0.572,  0.833,
		0.140,  0.616,  0.489,
		0.997,  0.513,  0.064,
		0.945,  0.719,  0.592,
		0.543,  0.021,  0.978,
		0.279,  0.317,  0.505,
		0.167,  0.620,  0.077,
		0.347,  0.857,  0.137,
		0.055,  0.953,  0.042,
		0.714,  0.505,  0.345,
		0.783,  0.290,  0.734,
		0.722,  0.645,  0.174,
		0.302,  0.455,  0.848,
		0.225,  0.587,  0.040,
		0.517,  0.713,  0.338,
		0.053,  0.959,  0.120,
		0.393,  0.621,  0.362,
		0.673,  0.211,  0.457,
		0.820,  0.883,  0.371,
		0.982,  0.099,  0.879
	];

	public function new(w:Int,h:Int,d:Int) {
		
		/*var canvas = js.Browser.document.createCanvasElement();
		canvas.width = 400;
		canvas.height = 400;
		js.Browser.document.body.appendChild(canvas);

		
		var ctx = canvas.getContext2d();
				var img = new js.html.Image();  
				img.onload = function() {  
					ctx.drawImage(img,0,0);
					var i = ctx.getImageData(0,0,128,128);
		*/// Define vertex structure
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        structure.add("col", VertexData.Float3);
        // Save length - we store position and color data
        var structureLength = 6;
		/**
			
	static inline var TEXTURE_CUBE_MAP : Int = 34067;
	static inline var TEXTURE_BINDING_CUBE_MAP : Int = 34068;
	static inline var TEXTURE_CUBE_MAP_POSITIVE_X : Int = 34069;
	static inline var TEXTURE_CUBE_MAP_NEGATIVE_X : Int = 34070;
	static inline var TEXTURE_CUBE_MAP_POSITIVE_Y : Int = 34071;
	static inline var TEXTURE_CUBE_MAP_NEGATIVE_Y : Int = 34072;
	static inline var TEXTURE_CUBE_MAP_POSITIVE_Z : Int = 34073;
	static inline var TEXTURE_CUBE_MAP_NEGATIVE_Z : Int = 34074;
		**/
		var texture = kha.SystemImpl.gl.createTexture();
		kha.SystemImpl.gl.bindTexture(34067, texture);

		var image = Assets.images.sky;

		var faceInfos = [
			34069,
34070,
34071,
34072,
34073,
34074
		  ];
		  for (i in 0...faceInfos.length) {
			var target = faceInfos[i];
		   
			// Upload the canvas to the cubemap face.
			var level = 0;
			var internalFormat = 6408;
			var width = 512;
			var height = 512;
			var format = 6408;
			var type = 5121;
		   
			// setup each face so it's immediately renderable
		   
			SystemImpl.gl.bindTexture(34067, texture);
			var pixels = Assets.images.get("sky").getPixels();
			//SystemImpl.gl.texImage2D(target, level, internalFormat, width, height, 0, format, type, image.getPixels());
			SystemImpl.gl.generateMipmap(34067);
		  }
		  SystemImpl.gl.generateMipmap(34067);
		  SystemImpl.gl.texParameteri(34067, 10241, 9987);




		// Compile pipeline state
		// Shaders are located in 'Sources/Shaders' directory
        // and Kha includes them automatically
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.sky_frag;
		pipeline.vertexShader = Shaders.sky_vert;
		// Set depth mode
        pipeline.depthWrite = true;
        pipeline.depthMode = CompareMode.Less;
		pipeline.compile();

		// Get a handle for our "MVP" uniform
		mvpID = pipeline.getConstantLocation("MVP");

		// Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
		var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		// Or, for an ortho camera
		//var projection = FastMatrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates
		
		// Camera matrix
		var view = FastMatrix4.lookAt(new FastVector3(4, 3, 3), // Camera is at (4, 3, 3), in World Space
								  new FastVector3(0, 0, 0), // and looks at the origin
								  new FastVector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Model matrix: an identity matrix (model will be at the origin)
		var model = FastMatrix4.identity();
		// Our ModelViewProjection: multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);
		var vertices: Array<Float> = [
			-w,-h,-d,
			-w,-h, d,
			-w, h, d,
			 w, h,-d,
			-w,-h,-d,
			-w, h,-d,
			 w,-h, d,
			-w,-h,-d,
			 w,-h,-d,
			 w, h,-d,
			 w,-h,-d,
			-w,-h,-d,
			-w,-h,-d,
			-w, h, d,
			-w, h,-d,
			 w,-h, d,
			-w,-h, d,
			-w,-h,-d,
			-w, h, d,
			-w,-h, d,
			 w,-h, d,
			 w, h, d,
			 w,-h,-d,
			 w, h,-d,
			 w,-h,-d,
			 w, h, d,
			 w,-h, d,
			 w, h, d,
			 w, h,-d,
			-w, h,-d,
			 w, h, d,
			-w, h,-d,
			-w, h, d,
			 w, h, d,
			-w, h, d,
			 w,-h, d
		];
		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(vertices.length / 3), // Vertex count - 3 floats per vertex
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);
		
		// Copy vertices and colors to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...Std.int(vbData.length / structureLength)) {
			vbData.set(i * structureLength, vertices[i * 3]);
			vbData.set(i * structureLength + 1, vertices[i * 3 + 1]);
			vbData.set(i * structureLength + 2, vertices[i * 3 + 2]);
			vbData.set(i * structureLength + 3, colors[i * 3]);
			vbData.set(i * structureLength + 4, colors[i * 3 + 1]);
			vbData.set(i * structureLength + 5, colors[i * 3 + 2]);
		}
		vertexBuffer.unlock();

		// A 'trick' to create indices for a non-indexed vertex data
		var indices:Array<Int> = [];
		for (i in 0...Std.int(vertices.length / 3)) {
			indices.push(i);
		}

		// Create index buffer
		indexBuffer = new IndexBuffer(
			indices.length, // Number of indices for our cube
			Usage.StaticUsage // Index data will stay the same
		);
		
		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = indices[i];
		}
		indexBuffer.unlock();
		
		//	};  
		//	img.src = "water.jpg";
    }

	public function render(frames:Array<Framebuffer>, mvp: FastMatrix4) {
		var frame = frames[0];
		// A graphics object which lets us perform 3D operations
		var g = frame.g4;
			if (g!=null && vertexBuffer != null) {
				
		// Begin rendering
        g.begin();

        // Clear screen
		//g.clear(Color.fromFloats(0.0, 0.0, 0.3), 1.0);

		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Bind state we want to draw with
		g.setPipeline(pipeline);

		// Set our transformation to the currently bound shader, in the "MVP" uniform
		g.setMatrix(mvpID, mvp);

		// Draw!
		g.drawIndexedVertices();

		// End rendering
		g.end();
	}
    }
}
