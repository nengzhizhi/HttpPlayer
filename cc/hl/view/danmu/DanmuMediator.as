package cc.hl.view.danmu {

	import org.puremvc.as3.patterns.mediator.Mediator;
	import org.puremvc.as3.interfaces.*;

	import cc.hl.model.comment.*;

	public class DanmuMediator extends Mediator implements IMediator {

		public function DanmuMediator(obj:Object) {
			super("DanmuMediator", obj);
		}

		override public function listNotificationInterests() :Array {
			return [
						Order.Danmu_Init_Request,
						Order.Danmu_Show_Request,
						Order.Danmu_Hide_Request,
						Order.Danmu_Add_Request,
						Order.On_Resize
					];
		}

		override public function handleNotification(notify:INotification):void{
			switch(notify.getName()){
				case Order.Danmu_Init_Request:
					this.initDanmu();
					break;
				case Order.Danmu_Show_Request:
					this.danmuView.showDanmu();
					break;
				case Order.Danmu_Hide_Request:
					this.danmuView.hideDanmu();
					break;
				case Order.Danmu_Add_Request:
					this.addDanmu(notify.getBody());
					break;
				case Order.On_Resize:
					this.onResize(notify.getBody());
					break;
			}
		}

		private function initDanmu():void{
			this.danmuView.initDanmu();
			if(this.danmuView.parent == null){
				GlobalData.DANMU_LAYER.addChild(this.danmuView);
				this.danmuView.resize(GlobalData.root.stage.stageWidth, GlobalData.root.stage.stageHeight);
			}
		}

		private function addDanmu(obj:Object):void{
			CommentTime.instance.start(new SingleCommentData(
											obj.message,
											16777215,
											GlobalData.textSizeValue,
											0,
											false
				));
		}

		private function onResize(obj:Object):void{
			this.danmuView.resize(obj.w, obj.h);
		}

		public function get danmuView() : DanmuView {
			return viewComponent as DanmuView;
		}		
	}
}