package;
import js.Syntax;
import kha.graphics5_.TextureFormat;
import kha.WebGLImage;
import kha.js.graphics4.TextureUnit;
import kha.SystemImpl;
import VectorMath.inverse;
import koui.Koui;
import koui.elements.*;

import primitive.Primitive;
import primitive.SkyCubeModel;
import kha.input.KeyCode;
import kha.Framebuffer;
import kha.Color;
import kha.Assets;
import kha.Scheduler;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import noisetile.NoiseTile;
import primitive.PlaneModel;
import primitive.TerrainModel;
import instances.Instances;
import primitive.GL;

class PlaneInstance {

	var planes:Array<TerrainModel>;
	var planes2:Array<PlaneModel>;
	var sky: SkyCubeModel;
	var mvp:FastMatrix4;
	var invmvp:FastMatrix4;

	var model:FastMatrix4;
	var view:FastMatrix4;
	var projection:FastMatrix4;

	public var moveForward = false;
	public var moveBackward = false;
	public var strafeLeft = false;
	public var strafeRight = false;

	var isMouseDown = false;
	var mouseX = 0.0;
	var mouseY = 0.0;
	var mouseDeltaX = 0.0;
	var mouseDeltaY = 0.0;

	var speed = 2000.0; // 3 units / second
	var mouseSpeed = 0.01;

	var lastTime = 0.0;
	var position:FastVector3 = new FastVector3(0, 100, 5); // Initial position: on +Z
	var horizontalAngle = 3.14; // Initial horizontal angle: toward -Z
	var verticalAngle = 0.0; // Initial vertical angle: none
	var instancesCollection:Instances;

	var lastPosition:FastVector3;

	var gridSize = 6;
	var tilePx :Int = 50;
	var tileSize :Int = 5000;
	public var nt:Dynamic;

	public function new() {
		Assets.loadEverything(loadingFinished);
	}

	public function loadingFinished() {
		nt = new NoiseTile(gridSize, gridSize, tilePx);
		planes = new Array();
		planes2 = new Array();

		for (j in 0...gridSize)
			for (i in 0...gridSize){
				planes.push(new TerrainModel(nt.t.tiles[i + j * gridSize],nt.t.normals[i + j * gridSize], i, j, {
					w: tileSize,
					h: tileSize,
					x: tilePx,
					y: tilePx
				}));
			}

		// water & sky
		 planes2.push(new PlaneModel(0,0,{ w:90000, h:90000, x:2, y:2 }));
		 sky = new SkyCubeModel(40000,40000,40000);

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

		//instancesCollection = new Instances('grass',10,10,model,view,projection,mvp);

		// Add mouse and keyboard listeners
		kha.input.Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp);

		// Used to calculate delta time
		lastTime = Scheduler.time();
	}

	public function update() {
		if (position != lastPosition) {
			var xx = Std.int(position.z/tilePx/2);
			var zz = Std.int(position.x/tilePx/2);
			
			var h = 150+NoiseTile.getHeight(xx,zz);//5000+ nt.t.tiles[0][0][zz*tilePx+xx]; //+NoiseTile.getHeight(Std.int(-position.x/tileSize*tilePx),Std.int(-position.z/tileSize*tilePx));

			if (h < 150)
				h=150;
			position.y = h;
		}
		lastPosition = position;

		/*if (instancesCollection != null)
			instancesCollection.updateAll(); */
		
		// Compute time difference between current and last frame
		var deltaTime = Scheduler.time() - lastTime;
		lastTime = Scheduler.time();

		// Compute new orientation
		if (isMouseDown) {
			horizontalAngle += mouseSpeed * mouseDeltaX * -1;
			verticalAngle += mouseSpeed * mouseDeltaY * -1;
		}

		// Direction : Spherical coordinates to Cartesian coordinates conversion
		var direction = new FastVector3(Math.cos(verticalAngle) * Math.sin(horizontalAngle), Math.sin(verticalAngle),
			Math.cos(verticalAngle) * Math.cos(horizontalAngle));

		// Right vector
		var right = new FastVector3(Math.sin(horizontalAngle - 3.14 / 2.0), 0, Math.cos(horizontalAngle - 3.14 / 2.0));

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
		
		var invView = FastMatrix4.lookAt(new FastVector3(position.x,-position.y,position.z), // Camera is here
			look, // and looks here : at the same position, plus "direction"
			up // Head is up (set to (0, -1, 0) to look upside-down)
		);

		
		// Update model-view-projection matrix
		invmvp = FastMatrix4.identity();
		if (projection != null)
			invmvp = invmvp.multmat(projection);
		if (invView != null)
			invmvp = invmvp.multmat(invView);
		if (model != null)
			invmvp = invmvp.multmat(model);
		
		// Update model-view-projection matrix
		mvp = FastMatrix4.identity();
		if (projection != null)
			mvp = mvp.multmat(projection);
		if (view != null)
			mvp = mvp.multmat(view);
		if (model != null)
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

	// Create callback functions for when keys are pressed
	public function onKeyDown(key:kha.input.KeyCode):Void {
		
		if (key == KeyCode.Up)
			this.moveForward = true;
		else if (key == KeyCode.Down)
			moveBackward = true;
		else if (key == KeyCode.Left)
			strafeLeft = true;
		else if (key == KeyCode.Right)
			strafeRight = true;
	}

	public function onKeyUp(key:kha.input.KeyCode):Void {
		
		if (key == KeyCode.Up)
			moveForward = false;
		else if (key == KeyCode.Down)
			moveBackward = false;
		else if (key == KeyCode.Left)
			strafeLeft = false;
		else if (key == KeyCode.Right)
			strafeRight = false;
	}

	public function render(frames:Array<Framebuffer>){

		var frame = frames[0];
		var g = frame.g4;

		var frame = frames[0];
		var g = frame.g4;
		g.begin();
			
	var gl = SystemImpl.gl;
	// Create a texture to render to
	var targetTextureWidth = 128;
	var targetTextureHeight = 128;
	var targetTexture = gl.createTexture();
	gl.bindTexture(GL.TEXTURE_2D, targetTexture);

	{
	// define size and format of level 0
	var level = 0;
	var internalFormat = GL.RGBA;
	var border = 0;
	var format = GL.RGBA;
	var type = GL.UNSIGNED_BYTE;
	var data = null;
	gl.texImage2D(GL.TEXTURE_2D, level, internalFormat,
					targetTextureWidth, targetTextureHeight, border,
					format, type, data);

	// set the filtering so we don't need mips
	gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
	gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
	gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
	}

	// Create and bind the framebuffer
	var fb = gl.createFramebuffer();
	gl.bindFramebuffer(GL.FRAMEBUFFER, fb);

	// attach the texture as the first color attachment
	var attachmentPoint = GL.COLOR_ATTACHMENT0;
	var level = 0;
	gl.framebufferTexture2D(GL.FRAMEBUFFER, attachmentPoint, GL.TEXTURE_2D, targetTexture, level);

	gl.enable(GL.CULL_FACE);
	gl.enable(GL.DEPTH_TEST);

    {
      // render to our targetTexture by binding the framebuffer
      gl.bindFramebuffer(GL.FRAMEBUFFER, fb);

      // Tell WebGL how to convert from clip space to pixels
      gl.viewport(0, 0, targetTextureWidth, targetTextureHeight);

      // Clear the attachment(s).
      gl.clearColor(0, 0, 0, 1);   // clear
      gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

	  
	}
		if (planes != null)
			for (plane in planes)
				plane.drawPlane(frame, mvp);

		g.end();

		// render to the canvas
		gl.bindFramebuffer(GL.FRAMEBUFFER, null);

		// render the cube with the texture we just rendered to
		gl.bindTexture(GL.TEXTURE_2D, targetTexture);
  
		// Tell WebGL how to convert from clip space to pixels
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
		// Clear the attachment(s).
		gl.clearColor(0, 0, 0, 1);   // clear to blue
		gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

		g.begin();

		if (planes != null)
			for (plane in planes)
				plane.drawPlane(frame, mvp);

		if (planes2!=null)
				for (plane in planes2)
					plane.drawPlane(frame,mvp,targetTexture);

		if (sky != null)
			sky.render(frame, mvp);
		
			if (instancesCollection != null) {
				instancesCollection.render(frame,model,view,projection);
		}

		g.end();

		Koui.render(frame.g2);

	}
}
