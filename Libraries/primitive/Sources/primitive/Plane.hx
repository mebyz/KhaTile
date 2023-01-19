package primitive;

import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class Plane extends Shape {

	public function new(w:Float, h:Float, segmentsX:Int = 2, segmentsY:Int = 2, uvsX:Int = 1, uvsY:Int = 1,
						heightData:Array<Int> = null,idx:Int = 0,idy:Int = 0) {

		super();

		var vertices = new Array<Float>();
		var stepX = w / (segmentsX - 1);
		var stepY = h / (segmentsY - 1);
		uvsBuffer = new Array();
		for (j in 0...segmentsY) {
			for (i in 0...segmentsX) {
				vertices.push(i * stepX - w / 2+idx*w);

				if (heightData == null) 
					vertices.push(-350.0);
				else 
					vertices.push((heightData[j * segmentsX + i]+50) / 1 );
				
				vertices.push(j * stepY - h / 2+idy*h);
			
				uvsBuffer.push((i)/100);
				uvsBuffer.push((j)/100);

			}
		}
    
		var n:Int = 0;
		var colSteps:Int = segmentsX * 2;
		var rowSteps:Int = segmentsY - 1;
		var indices = new Array<Int>();

		for (r in 0...rowSteps) {
		    for (c in 0...colSteps) {
		        var t:Int = c + r * colSteps;

		        if (c == colSteps - 1) {
		            indices.push(n);
		        }
		        else {
		            indices.push(n);

		            if (t % 2 == 0) {
		                n += segmentsX;
		            }
		            else {
		                (r % 2 == 0) ? n -= (segmentsX - 1) : n -= (segmentsX + 1);
		            }
		        }

		        if (t > 0 && t % (segmentsX * 2) == 0)  indices.pop();
		    }
		}

		var ind:Array<Int> = new Array();

		for (i in 0...indices.length) {
			ind.push(indices[i]);

			if (i > 1) {
				ind.push(indices[i - 1]);
				ind.push(indices[i]);
			}
		}

		var structure : VertexStructure = getVertexStructure();

		vertexBuffer = new VertexBuffer(
			Std.int(vertices.length / 3), // 3 floats per vertex
			structure, 
			Usage.StaticUsage 
		);
		
		var vbData = vertexBuffer.lock();
//		for (i in 0...vbData.length) {
//			vbData.set(i, vertices[i]);
//		}
		var structureLength=5;
		for (i in 0...Std.int(vbData.length / structureLength)) {
		  vbData.set(i * structureLength, vertices[i * 3]);
		  vbData.set(i * structureLength + 1, vertices[i * 3 + 1]);
		  vbData.set(i * structureLength + 2, vertices[i * 3 + 2]);
		  vbData.set(i * structureLength + 3, uvsBuffer[i * 2]);
		  vbData.set(i * structureLength + 4, uvsBuffer[i * 2 + 1]);
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