package cc.hl.model.video.platform{

	import flash.events.*;
	import asunit.framework.TestCase;
	import cc.hl.model.video.base.*;

	public class YoukuVideoInfoTest extends TestCase{
		private var youkuVideoInfo:YoukuVideoInfo;

		public function YoukuVideoInfoTest(methodName:String=null) {
			super(methodName);
		}

		override protected function setUp():void{
			super.setUp();
			youkuVideoInfo = new YoukuVideoInfo("XODg1OTc2MzUy");
		}

		override protected function tearDown():void {
			super.tearDown();
			youkuVideoInfo = null;
		}

		public function testGetPartVideoInfo():void{
			youkuVideoInfo.init();
			youkuVideoInfo.addEventListener(Event.COMPLETE,function():void{
				youkuVideoInfo.getPartVideoInfo(
					function(partVideoInfo:PartVideoInfo):void{
						trace(partVideoInfo.url);

				
					youkuVideoInfo.getPartVideoInfo(
						function(partVideoInfo:PartVideoInfo):void{
							trace(partVideoInfo.url);
						}, 0, 0);

					}, 0, 0);			
			});			
		}
	} 

}