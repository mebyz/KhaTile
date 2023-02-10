package;

import haxe.Timer;
import kha.Assets;
import koui.utils.RadioGroup;
import js.Browser;
import kha.WindowOptions;
import kha.Canvas;
import kha.Image;
import kha.Scheduler;
import kha.System;
import koui.Koui;
import koui.events.MouseEvent;
import koui.elements.*;
import io.colyseus.Client;
import io.colyseus.Room;
import aura.Aura;

class Main {

	public var mySound: kha.Sound;
	public static function main() {
		#if hotml new hotml.client.Client(); #end
		setFullWindowCanvas();
		var client = new Client('ws://localhost:2567');
		
		System.start({title: "PlaneInstance"}, function(_) {

			var loadConfig: AuraLoadConfig = {
					
				uncompressed: ["sound"],
			};

			Aura.init();
			
			Aura.loadAssets(loadConfig, () -> {
			Koui.init(() -> {


				var pb = new Progressbar(0,100);
				pb.setPosition(300,300);
				pb.precision = 0;

				Koui.add(pb);
				

					Timer.delay(function() { pb.set_value(10); }, 1000);
					Timer.delay(function() { pb.set_value(70); }, 5000);
					Timer.delay(function() { pb.set_value(100); 
						var button = new Button("Click me!");
						button.setPosition(300, 300);
						pb.visible = false;
						Koui.add(button);	
						button.addEventListener(MouseClickEvent, function(e: MouseClickEvent) {
							switch (e.getState()) {
								case ClickStart:
									Aura.createHandle(Play, Aura.getSound("sound")).play();
								case ClickEnd:
										button.visible = false;
								default:
							}
						});
					
					}, 10000);

					
	



				var rg = new RadioGroup();
				var rb1 = new RadioButton(rg,"test1");
                rb1.setPosition(10, 50);
				var rb2 = new RadioButton(rg,"test2");
                rb2.setPosition(10, 100);
				var mySlider = new Slider(0, 100);
				mySlider.setPosition(10,150);
				mySlider.precision = 0;
				mySlider.height = 10;
               
                //Koui.add(rb1);
                //Koui.add(rb2);
				//Koui.add(mySlider);

				var game = new PlaneInstance();

				Scheduler.addTimeTask(function() {
					game.update();
				}, 0, 1 / 50);
				System.notifyOnFrames(function(f) {
					game.render(f);
				});
            });
			
		});

				
		});
	}
	static function setFullWindowCanvas():Void {
		#if js
		var script = js.Browser.document.createElement("script");
		script.innerHTML = '(function(){var script=document.createElement("script");(function(l,h){function e(a,d){if(null==d)return null;null==d.__id__&&(d.__id__=k++);var c;null==a.hx__closures__?a.hx__closures__={}:c=a.hx__closures__[d.__id__];null==c&&(c=function(){return c.method.apply(c.scope,arguments)},c.scope=a,c.method=d,a.hx__closures__[d.__id__]=c);return c}var a=h.Perf=function(g,d){null==d&&(d=0);null==g&&(g="TR");this._perfObj=window.performance;null!=f.field(this._perfObj,"memory")&&(this._memoryObj=f.field(this._perfObj,"memory"));this._memCheck=null!=this._perfObj&&
			null!=this._memoryObj&&0<this._memoryObj.totalJSHeapSize;this._pos=g;this._offset=d;this.currentFps=60;this.currentMs=0;this.currentMem="0";this.avgFps=this.lowFps=60;this._ticks=this._time=this._totalFps=this._measureCount=0;this._fpsMax=this._fpsMin=60;null!=this._perfObj&&null!=(b=this._perfObj,e(b,b.now))?this._startTime=this._perfObj.now():this._startTime=(new Date).getTime();this._prevTime=-a.MEASUREMENT_INTERVAL;this._createFpsDom();this._createMsDom();this._memCheck&&this._createMemoryDom();
			null!=(b=window,e(b,b.requestAnimationFrame))?this.RAF=(b=window,e(b,b.requestAnimationFrame)):null!=window.mozRequestAnimationFrame?this.RAF=window.mozRequestAnimationFrame:null!=window.webkitRequestAnimationFrame?this.RAF=window.webkitRequestAnimationFrame:null!=window.msRequestAnimationFrame&&(this.RAF=window.msRequestAnimationFrame);null!=(b=window,e(b,b.cancelAnimationFrame))?this.CAF=(b=window,e(b,b.cancelAnimationFrame)):null!=window.mozCancelAnimationFrame?this.CAF=window.mozCancelAnimationFrame:
				null!=window.webkitCancelAnimationFrame?this.CAF=window.webkitCancelAnimationFrame:null!=window.msCancelAnimationFrame&&(this.CAF=window.msCancelAnimationFrame);null!=this.RAF&&(this._raf=f.callMethod(window,this.RAF,[e(this,this._tick)]))};a.prototype={_init:function(){this.currentFps=60;this.currentMs=0;this.currentMem="0";this.avgFps=this.lowFps=60;this._ticks=this._time=this._totalFps=this._measureCount=0;this._fpsMax=this._fpsMin=60;null!=this._perfObj&&null!=(b=this._perfObj,e(b,b.now))?this._startTime=
			this._perfObj.now():this._startTime=(new Date).getTime();this._prevTime=-a.MEASUREMENT_INTERVAL},_now:function(){return null!=this._perfObj&&null!=(b=this._perfObj,e(b,b.now))?this._perfObj.now():(new Date).getTime()},_tick:function(g){var d;d=null!=this._perfObj&&null!=(b=this._perfObj,e(b,b.now))?this._perfObj.now():(new Date).getTime();this._ticks++;null!=this._raf&&d>this._prevTime+a.MEASUREMENT_INTERVAL&&(this.currentMs=Math.round(d-this._startTime),this.ms.innerHTML="MS: "+this.currentMs,this.currentFps=
			Math.round(1E3*this._ticks/(d-this._prevTime)),0<this.currentFps&&g>a.DELAY_TIME&&(this._measureCount++,this._totalFps+=this.currentFps,this.lowFps=this._fpsMin=Math.min(this._fpsMin,this.currentFps),this._fpsMax=Math.max(this._fpsMax,this.currentFps),this.avgFps=Math.round(this._totalFps/this._measureCount)),this.fps.innerHTML="FPS: "+this.currentFps+" ("+this._fpsMin+"-"+this._fpsMax+")",this.fps.style.backgroundColor=30<=this.currentFps?a.FPS_BG_CLR:15<=this.currentFps?a.FPS_WARN_BG_CLR:a.FPS_PROB_BG_CLR,
			this._prevTime=d,this._ticks=0,this._memCheck&&(this.currentMem=this._getFormattedSize(this._memoryObj.usedJSHeapSize,2),this.memory.innerHTML="MEM: "+this.currentMem));this._startTime=d;null!=this._raf&&(this._raf=f.callMethod(window,this.RAF,[e(this,this._tick)]))},_createDiv:function(b,d){null==d&&(d=0);var c;c=window.document.createElement("div");c.id=b;c.className=b;c.style.position="absolute";switch(this._pos){case "TL":c.style.left=this._offset+"px";c.style.top=d+"px";break;case "TR":c.style.right=
			this._offset+"px";c.style.top=d+"px";break;case "BL":c.style.left=this._offset+"px";c.style.bottom=(this._memCheck?48:32)-d+"px";break;case "BR":c.style.right=this._offset+"px",c.style.bottom=(this._memCheck?48:32)-d+"px"}c.style.width="80px";c.style.height="12px";c.style.lineHeight="12px";c.style.padding="2px";c.style.fontFamily=a.FONT_FAMILY;c.style.fontSize="9px";c.style.fontWeight="bold";c.style.textAlign="center";window.document.body.appendChild(c);return c},_createFpsDom:function(){this.fps=
			this._createDiv("fps");this.fps.style.backgroundColor=a.FPS_BG_CLR;this.fps.style.zIndex="995";this.fps.style.color=a.FPS_TXT_CLR;this.fps.innerHTML="FPS: 0"},_createMsDom:function(){this.ms=this._createDiv("ms",16);this.ms.style.backgroundColor=a.MS_BG_CLR;this.ms.style.zIndex="996";this.ms.style.color=a.MS_TXT_CLR;this.ms.innerHTML="MS: 0"},_createMemoryDom:function(){this.memory=this._createDiv("memory",32);this.memory.style.backgroundColor=a.MEM_BG_CLR;this.memory.style.color=a.MEM_TXT_CLR;this.memory.style.zIndex=
			"997";this.memory.innerHTML="MEM: 0"},_getFormattedSize:function(a,d){null==d&&(d=0);if(0==a)return"0";var c=Math.pow(10,d),b=Math.floor(Math.log(a)/Math.log(1024));return Math.round(a*c/Math.pow(1024,b))/c+" "+["Bytes","KB","MB","GB","TB"][b]},addInfo:function(b){this.info=this._createDiv("info",this._memCheck?48:32);this.info.style.backgroundColor=a.INFO_BG_CLR;this.info.style.color=a.INFO_TXT_CLR;this.info.style.zIndex="998";this.info.innerHTML=b},clearInfo:function(){null!=this.info&&(window.document.body.removeChild(this.info),
			this.info=null)},destroy:function(){f.callMethod(window,this.CAF,[this._raf]);this._memoryObj=this._perfObj=this._raf=null;null!=this.fps&&(window.document.body.removeChild(this.fps),this.fps=null);null!=this.ms&&(window.document.body.removeChild(this.ms),this.ms=null);null!=this.memory&&(window.document.body.removeChild(this.memory),this.memory=null);this.clearInfo();this.currentFps=60;this.currentMs=0;this.currentMem="0";this.avgFps=this.lowFps=60;this._ticks=this._time=this._totalFps=this._measureCount=
			0;this._fpsMax=this._fpsMin=60;null!=this._perfObj&&null!=(b=this._perfObj,e(b,b.now))?this._startTime=this._perfObj.now():this._startTime=(new Date).getTime();this._prevTime=-a.MEASUREMENT_INTERVAL},_cancelRAF:function(){f.callMethod(window,this.CAF,[this._raf]);this._raf=null}};var f=function(){};f.field=function(a,b){try{return a[b]}catch(c){return null}};f.callMethod=function(a,b,c){return b.apply(a,c)};var b,k=0;a.MEASUREMENT_INTERVAL=1E3;a.FONT_FAMILY="Helvetica,Arial";a.FPS_BG_CLR="#00FF00";
			a.FPS_WARN_BG_CLR="#FF8000";a.FPS_PROB_BG_CLR="#FF0000";a.MS_BG_CLR="#FFFF00";a.MEM_BG_CLR="#086A87";a.INFO_BG_CLR="#00FFFF";a.FPS_TXT_CLR="#000000";a.MS_TXT_CLR="#000000";a.MEM_TXT_CLR="#FFFFFF";a.INFO_TXT_CLR="#000000";a.TOP_LEFT="TL";a.TOP_RIGHT="TR";a.BOTTOM_LEFT="BL";a.BOTTOM_RIGHT="BR";a.DELAY_TIME=4E3})("undefined"!=typeof console?console:{log:function(){}},"undefined"!=typeof window?window:exports);
			var stats = new Perf(Perf.TOP_RIGHT, 0);document.head.appendChild(script);})();';
		js.Browser.document.body.appendChild(script);
		js.Browser.document.documentElement.style.padding = "0";
		js.Browser.document.documentElement.style.margin = "0";
		js.Browser.document.body.style.padding = "0";
		js.Browser.document.body.style.margin = "0";
		var canvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
		canvas.style.display = "block";
		final resize = function() {
			var w = js.Browser.document.documentElement.clientWidth;
			var h = js.Browser.document.documentElement.clientHeight;
			if (w == 0 || h == 0) {
				w = Browser.window.innerWidth;
				h = Browser.window.innerHeight;
			}
			canvas.width = Std.int(w * Browser.window.devicePixelRatio);
			canvas.height = Std.int(h * Browser.window.devicePixelRatio);
			if (canvas.style.width == "") {
				canvas.style.width = "100%";
				canvas.style.height = "100%";
			}
		}
		Browser.window.onresize = resize;
		resize();
		#end
	}
}
