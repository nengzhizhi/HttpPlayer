package cc.hl.model.video.part {

	import flash.events.*;
	import flash.net.*;
	import flash.display.*;
	import flash.media.*;
	import asunit.framework.TestCase;
	import cc.hl.model.video.base.*;
	import cc.hl.model.video.platform.*;

	public class FLVPartNetStreamTest extends TestCase{

		public function FLVPartNetStreamTest(methodName:String=null) {
			super(methodName);
		}

		override protected function setUp():void{
			super.setUp();
		}		

		override protected function tearDown():void{
			super.tearDown();
		}

		public function testInitStream():void{
			var nc:NetConnection = new NetConnection();
			nc.connect(null);

			var ns:PartNetStream = new FLVPartNetStream(nc);			

			var video:Video = new Video();
			video.smoothing = true;

			addChild(video);

			var youkuVideoInfo:YoukuVideoInfo = new YoukuVideoInfo("XODg1OTc2MzUy");
			youkuVideoInfo.init();
			youkuVideoInfo.addEventListener(Event.COMPLETE,function():void{
				youkuVideoInfo.getPartVideoInfo(
					function(partVideoInfo:PartVideoInfo):void{
						ns.load(partVideoInfo, true, 0);
						video.attachNetStream(ns);
					}, 0, 0);
			});
		}
	}
}