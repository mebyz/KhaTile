package;

import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CullMode;
import kha.math.Random;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Scheduler;
import kha.Shaders;
import kha.Assets;
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

	var planes : Array<TerrainModel>;
	var planes2 : Array<PlaneModel>;
	var mvp:FastMatrix4;

	public function new() {


		var gridSize = 20;
		var tilePx =16;
		var tileSize =32;

		var nt : Dynamic= new NoiseTile(gridSize,gridSize,tilePx);

		planes = new Array();
		planes2 = new Array();

		for (j in 0...gridSize)
			for (i in 0...gridSize)
				planes.push(new TerrainModel(nt.t.tiles[i+j*gridSize],i,j,{ w:tileSize, h:tileSize, x:tilePx, y:tilePx }));

		//water
		planes2.push(new PlaneModel(0,0,{ w:100000, h:100000, x:10, y:10 }));


		var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 10000.0);
		
		var view = FastMatrix4.lookAt(new FastVector3(500, 500, 500), // Camera at (4, 3, 3)
								  new FastVector3(0, 0, 0), //  look at origin
								  new FastVector3(0, 1, 0) // Head is up, set (0, -1, 0) to look upside down
		);

		var model = FastMatrix4.identity();
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

    }

	public function render(frame:Framebuffer) {
		var g = frame.g4;
	    g.begin();
		g.clear(Color.Black);
		/////
		/////
		for (plane in planes)
			plane.drawPlane(frame,mvp);
		for (plane in planes2)
			plane.drawPlane(frame,mvp);
		/////
		/////
		g.end();
    }
}