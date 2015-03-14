package cc.hl.view.danmu {
	import flash.display.Sprite;
	import cc.hl.model.comment.CommentPlugin;
	import flash.events.Event;

	public class DanmuView extends Sprite {
		private var _danmu:CommentPlugin;

		public function DanmuView() {
			super();
		}

		public function initDanmu():void{
			this._danmu = new CommentPlugin();
			addChild(this._danmu);
		}

		public function showDanmu():void{
			this._danmu.commentShow = true;
		}

		public function hideDanmu():void{
			this._danmu.commentShow = false;
		}

		public function resize(w:Number, h:Number):void{
			if(this._danmu != null){
				this._danmu.resize(w, h);
			}
		}

	}
}