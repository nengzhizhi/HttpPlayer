package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import common.event.*;
	import util.*;

	public class HttpPlayer extends Sprite
	{
		public function HttpPlayer()
		{
			super();
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");

			this.addEventListener(Event.ADDED_TO_STAGE,this._addStage);				
		}

		private var facade:MainCoreFacade;

		private function _addStage(e:Event):void{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.color = 0;
			stage.addEventListener(Event.RESIZE, this.onResize);

			GlobalData.root = this;
			GlobalData.STAGE = stage;

			var _loc2_:String = ExternalInterface.call("function getBrowser(){return navigator.userAgent;}");
			$.jscall("console.log","浏览器类型   = " + _loc2_);

			this.facade = MainCoreFacade.getInstance();
			this.facade.sendNotification("start_up",this);
			return;	
		}

		private function onResize(e:Event):void{
			EventCenter.dispatch("ResizeChange",
			{
				"w":stage.stageWidth,
				"h":stage.stageHeight
			});			
		}
	}
}