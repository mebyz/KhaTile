package;

import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CullMode;
import kha.math.Random;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Shaders;
import kha.Assets;
import kha.Scheduler;
import kha.Key;
import kha.graphics4.PipelineState;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.Matrix4;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import primitive.Primitive;
import noisetile.NoiseTile;
import primitive.PlaneModel;
import primitive.TerrainModel;

class PlaneInstance {
	//
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;
	var mvpID:ConstantLocation;
	//

	var planes : Array<TerrainModel>;
	var planes2 : Array<PlaneModel>;
	var mvp:FastMatrix4;

	var model:FastMatrix4;
	var view:FastMatrix4;
	var projection:FastMatrix4;

var moveForward = false;
    var moveBackward = false;
    var strafeLeft = false;
    var strafeRight = false;
	var isMouseDown = false;
	var mouseX = 0.0;
	var mouseY = 0.0;
	var mouseDeltaX = 0.0;
	var mouseDeltaY = 0.0;

	var speed = 2000.0; // 3 units / second
	var mouseSpeed = 0.005;

    var lastTime = 0.0;
    var position:FastVector3 = new FastVector3(0, 100, 5); // Initial position: on +Z
	var horizontalAngle = 3.14; // Initial horizontal angle: toward -Z
	var verticalAngle = 0.0; // Initial vertical angle: none

	public function new() {
		Assets.loadEverything(loadingFinished);
	}
	public function loadingFinished() {
		var gridSize = 10;
		var tilePx =16;
		var tileSize =500;

		var nt : Dynamic= new NoiseTile(gridSize,gridSize,tilePx);

		planes = new Array();
		planes2 = new Array();

		for (j in 0...gridSize)
			for (i in 0...gridSize)
				planes.push(new TerrainModel(nt.t.tiles[i+j*gridSize],i,j,{ w:tileSize, h:tileSize, x:tilePx, y:tilePx }));

		//water
		planes2.push(new PlaneModel(0,0,{ w:50000, h:50000, x:100, y:100 }));


		//

		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        structure.add("uv", VertexData.Float2);
        structure.add("nor", VertexData.Float3);
        // Save length - we store position, uv and normal data
        var structureLength = 8;

        // Compile pipeline state
		// Shaders are located in 'Sources/Shaders' directory
        // and Kha includes them automatically
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.red_vert;
		pipeline.fragmentShader = Shaders.red_frag;
		// Set depth mode
        pipeline.depthWrite = true;
        pipeline.depthMode = CompareMode.Less;
        // Set culling
        pipeline.cullMode = CullMode.CounterClockwise;
		pipeline.compile();

		// Get a handle for our "MVP" uniform
		mvpID = pipeline.getConstantLocation("MVP");
	
		var obj = new ObjLoader(Assets.blobs.grass_obj.toString());

		var data = obj.data;
		var indices = obj.indices;

		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(data.length / structureLength), // Vertex count
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);

		// Copy data to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, data[i]);
		}
		vertexBuffer.unlock();

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

		//


		projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100000.0);
		
		view = FastMatrix4.lookAt(new FastVector3(7, 0, 7), // Camera at (4, 3, 3)
								  new FastVector3(0, 0, 0), //  look at origin
								  new FastVector3(0, 1, 0) // Head is up, set (0, -1, 0) to look upside down
		);

		model = FastMatrix4.identity();
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		
		// Add mouse and keyboard listeners
		kha.input.Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp);

		// Used to calculate delta time
		lastTime = Scheduler.time();

    }


    public function update() {
    	// Compute time difference between current and last frame
		var deltaTime = Scheduler.time() - lastTime;
		lastTime = Scheduler.time();

		// Compute new orientation
		if (isMouseDown) {
			horizontalAngle += mouseSpeed * mouseDeltaX * -1;
			verticalAngle += mouseSpeed * mouseDeltaY * -1;
		}

		// Direction : Spherical coordinates to Cartesian coordinates conversion
		var direction = new FastVector3(
			Math.cos(verticalAngle) * Math.sin(horizontalAngle),
			Math.sin(verticalAngle),
			Math.cos(verticalAngle) * Math.cos(horizontalAngle)
		);
		
		// Right vector
		var right = new FastVector3(
			Math.sin(horizontalAngle - 3.14 / 2.0), 
			0,
			Math.cos(horizontalAngle - 3.14 / 2.0)
		);
		
		// Up vector
		var up = right.cross(direction);

		// Movement
		if (moveForward) {
			var v = direction.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (moveBackward) {
			var v = direction.mult(deltaTime * speed * -1);
			position = position.add(v);
		}
		if (strafeRight) {
			var v = right.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (strafeLeft) {
			var v = right.mult(deltaTime * speed * -1);
			position = position.add(v);
		}

		// Look vector
		var look = position.add(direction);
		
		// Camera matrix
		view = FastMatrix4.lookAt(position, // Camera is here
							  look, // and looks here : at the same position, plus "direction"
							  up // Head is up (set to (0, -1, 0) to look upside-down)
		);


		// Update model-view-projection matrix
		mvp = FastMatrix4.identity();
		if (projection !=null)
			mvp = mvp.multmat(projection);
		if (view !=null)
			mvp = mvp.multmat(view);
		if (model !=null)
			mvp = mvp.multmat(model);

		mouseDeltaX = 0;
		mouseDeltaY = 0;
    }

    function onMouseDown(button:Int, x:Int, y:Int) {
    	isMouseDown = true;
    }

    function onMouseUp(button:Int, x:Int, y:Int) {
    	isMouseDown = false;
    }

    function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int) {
    	mouseDeltaX = x - mouseX;
    	mouseDeltaY = y - mouseY;

    	mouseX = x;
    	mouseY = y;
    }

    function onKeyDown(key:Key, char:String) {
        if (key == Key.UP) moveForward = true;
        else if (key == Key.DOWN) moveBackward = true;
        else if (key == Key.LEFT) strafeLeft = true;
        else if (key == Key.RIGHT) strafeRight = true;
    }

    function onKeyUp(key:Key, char:String) {
        if (key == Key.UP) moveForward = false;
        else if (key == Key.DOWN) moveBackward = false;
        else if (key == Key.LEFT) strafeLeft = false;
        else if (key == Key.RIGHT) strafeRight = false;
    }

	public function render(frame:Framebuffer) {
		var g = frame.g4;
	    g.begin();
		g.clear(Color.Black);
		/////
		/////
		if (planes!=null)
			for (plane in planes)
				plane.drawPlane(frame,mvp);
		if (planes2!=null)
			for (plane in planes2)
				plane.drawPlane(frame,mvp);
		/////

		if (vertexBuffer !=null && indexBuffer !=null && pipeline !=null && mvpID !=null &&mvp !=null){

		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		// Bind state we want to draw with
		g.setPipeline(pipeline);
		// Set our transformation to the currently bound shader, in the "MVP" uniform
		g.setMatrix(mvpID, mvp);
		// Draw!
		g.drawIndexedVertices();
		}

		/////
		g.end();
    }
}