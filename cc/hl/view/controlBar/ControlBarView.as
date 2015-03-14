package cc.hl.view.controlBar {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;

	import ui.ControlBar;
	import util.*;

	public class ControlBarView extends Sprite {

		private var _controlBar:ControlBar;
		private var _videoSeconds:Number = 0;
		private var _progressBar:VideoProgressBar;
		private var _volume:Number;
		private var _volumeBak:Number;

		public static const CONTROL_BAR_HEIGHT:int = 40;
		public static const VOLUME_BAR_MAX:Number = 82;

		public function ControlBarView(){
			super();
			this._controlBar = new ControlBar();

			this._controlBar.playBtn.visible = false;
			this._controlBar.pauseBtn.visible = true;
			this._controlBar.timer.visible = true;
			this._controlBar.fullScreenBtn.visible = true;
			this._controlBar.normalScreenBtn.visible = false;
			this._controlBar.danmuShowBtn.visible = true;
			this._controlBar.danmuHideBtn.visible = false;

			this._controlBar.playBtn.addEventListener(MouseEvent.CLICK, this.onPlayBtnClicked);
			this._controlBar.volumeBtm.addEventListener(MouseEvent.CLICK,this.onVolumeBtmClicked);				
			(this._controlBar.volumeBtm as MovieClip).buttonMode = true;
			(this._controlBar.volumeBtm as MovieClip).gotoAndStop(1);
			this._controlBar.pauseBtn.addEventListener(MouseEvent.CLICK, this.onPauseBtnClicked);
			this._controlBar.fullScreenBtn.addEventListener(MouseEvent.CLICK, this.onFullScreen);
			this._controlBar.normalScreenBtn.addEventListener(MouseEvent.CLICK, this.onNormalScreen);
			this._controlBar.danmuShowBtn.addEventListener(MouseEvent.CLICK, this.onDanmuShow);
			this._controlBar.danmuHideBtn.addEventListener(MouseEvent.CLICK, this.onDanmuHide);
			(this._controlBar.danmuTag as MovieClip).gotoAndStop(1);

			this._progressBar = new VideoProgressBar();
			this._controlBar.addChildAt(this._progressBar, this._controlBar.getChildIndex(this._controlBar.playBtn));

			this.startVolumeBar();
			addChild(this._controlBar);
			addEventListener(Event.ADDED_TO_STAGE,this.onAddToStage);
		}

		private function onAddToStage(event:Event) : void {
			setTimeout(function():void{
				stage.addEventListener(MouseEvent.MOUSE_MOVE,controlBarAnimate);
				stage.addEventListener(Event.MOUSE_LEAVE,controlBarAnimate);
				controlBarAnimate(null);
			},5000);
		}

		public static const CONTROL_BAR_THRESHOLD:int = 200;
		private var _animateState:String = "showing";
		private var _controlBarAnimate:TweenLite;

		private function controlBarAnimate(event:Event = null) : void{
			if(stage == null){
				return;
			}

			if((event) && (event.type == MouseEvent.MOUSE_MOVE) && stage.stageHeight - stage.mouseY < CONTROL_BAR_THRESHOLD){
				if(this._animateState != "showing"){
					this._animateState = "showing";
					if(this._controlBarAnimate){
						this._controlBarAnimate.kill();
					}
					this._controlBarAnimate = TweenLite.to(this,0.5,{
							"y":stage.stageHeight - CONTROL_BAR_HEIGHT,
							"alpha":1,
							"ease":Cubic.easeOut
						});
				}
			}
			else if(this._animateState != "hiding"){
				this._animateState = "hiding";
				if(this._controlBarAnimate){
					this._controlBarAnimate.kill();
				}
				this._controlBarAnimate = TweenLite.to(this,0.5,{
						"y":stage.stageHeight,
						"alpha":0,
						"ease":Cubic.easeOut
					});				
			}
		}

		public function resize(w:Number, h:Number) : void{
			this._controlBar.background.width = w;
			this._controlBar.background.height = h;
			this._controlBar.fullScreenBtn.x = this._controlBar.background.width - this._controlBar.fullScreenBtn.width - 20;
			this._controlBar.normalScreenBtn.x = this._controlBar.background.width - this._controlBar.normalScreenBtn.width - 20;
			this._controlBar.danmuTag.x = this._controlBar.fullScreenBtn.x - 70;
			this._controlBar.danmuShowBtn.x = this._controlBar.danmuTag.x - 30;
			this._controlBar.danmuHideBtn.x = this._controlBar.danmuTag.x - 30;
			this._controlBar.volumeBar.x = this._controlBar.danmuHideBtn.x - this._controlBar.volumeBar.width - 20;
			this._controlBar.volumeBtm.x = this._controlBar.volumeBar.x - 31;			

			if(this.progressBar != null){
				this.progressBar.setWidth(w);
			}
			this.y = GlobalData.root.stage.stageHeight - CONTROL_BAR_HEIGHT;
		}

		private function startVolumeBar() : void {
			this._volume = 1;
			this._volumeBak = 1;
			var startVolumeDrag:Function = null;
			var endVolumeDrag:Function = null;
			var volumeDrag:Function = null;

			startVolumeDrag = function(param1:MouseEvent):void{
				stage.addEventListener(MouseEvent.MOUSE_MOVE,volumeDrag);
				stage.addEventListener(MouseEvent.MOUSE_UP,endVolumeDrag);
			};
			endVolumeDrag = function(param1:MouseEvent):void{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,volumeDrag);
				stage.removeEventListener(MouseEvent.MOUSE_UP,endVolumeDrag);				
			};
			volumeDrag = function(param1:MouseEvent):void{
				var _loc2_:Number = _controlBar.volumeBar.mouseX;
				if(_loc2_ < 0){ _loc2_ = 0; }
				if(_loc2_ > VOLUME_BAR_MAX){ _loc2_ = VOLUME_BAR_MAX; }
				volume =  _loc2_ / VOLUME_BAR_MAX;
			};

			this._controlBar.volumeBar.tg.x = VOLUME_BAR_MAX;
			this._controlBar.volumeBar.slider.width = VOLUME_BAR_MAX;
			this._controlBar.volumeBar.tg.addEventListener(MouseEvent.MOUSE_DOWN,startVolumeDrag);
			this._controlBar.volumeBar.addEventListener(MouseEvent.CLICK,volumeDrag);
		}

		protected function onPlayBtnClicked(event:MouseEvent) : void{
			this._controlBar.playBtn.visible = false;
			this._controlBar.pauseBtn.visible = true;
			dispatchEvent(new Event("CONTROL_BAR_PLAY"));
		}

		protected function onPauseBtnClicked(event:MouseEvent):void{
			this._controlBar.playBtn.visible = true;
			this._controlBar.pauseBtn.visible = false;
			dispatchEvent(new Event("CONTROL_BAR_PAUSE"));
		}

		protected function onFullScreen(event:MouseEvent):void{
			this._controlBar.fullScreenBtn.visible = false;
			this._controlBar.normalScreenBtn.visible = true;
			dispatchEvent(new Event("CONTROL_BAR_FULLSCREEN"));
		}

		protected function onNormalScreen(event:MouseEvent):void{
			this._controlBar.fullScreenBtn.visible = true;
			this._controlBar.normalScreenBtn.visible = false;
			dispatchEvent(new Event("CONTROL_BAR_NORMALSCREEN"));
		}

		protected function onVolumeBtmClicked(param1:MouseEvent) : void {
			if(this._volume == 0){
				this.volume = this._volumeBak;
				(this._controlBar.volumeBtm as MovieClip).gotoAndStop(1);
				dispatchEvent(new SkinEvent("CONTROL_BAR_VOLUME", this._volumeBak));				
			}
			else{
				this._volumeBak = this.volume;
				this.volume = 0;
				(this._controlBar.volumeBtm as MovieClip).gotoAndStop(2);
				dispatchEvent(new SkinEvent("CONTROL_BAR_VOLUME", 0));				
			}
		}

		protected function onDanmuShow(event:MouseEvent):void{
			this._controlBar.danmuShowBtn.visible = false;
			this._controlBar.danmuHideBtn.visible = true;
			(this._controlBar.danmuTag as MovieClip).gotoAndStop(2);
			dispatchEvent(new Event("CONTROL_BAR_HIDE_DANMU"));
		}

		protected function onDanmuHide(event:MouseEvent):void{
			this._controlBar.danmuShowBtn.visible = true;
			this._controlBar.danmuHideBtn.visible = false;
			(this._controlBar.danmuTag as MovieClip).gotoAndStop(1);
			dispatchEvent(new Event("CONTROL_BAR_SHOW_DANMU"));
		}

		public function get controlBar():ControlBar{
			return this._controlBar;
		}

		public function get volume():Number{
			return this._volume;
		}

		public function set volume(param1:Number): void{
			var _loc2_:* = NaN;
			if(param1 != this._volume){
				if(param1 != this._volume){
					if(param1 < 0){
						param1 = 0;
					}
					if(param1 > 1){
						param1 = 1;
					}
					this._volume = param1;
					_loc2_ = param1 * VOLUME_BAR_MAX;
					this._controlBar.volumeBar.tg.x = _loc2_;
					this._controlBar.volumeBar.slider.width = _loc2_;

					if(this._volume == 0){
						if((this._controlBar.volumeBtm as MovieClip).currentFrame == 1){
							(this._controlBar.volumeBtm as MovieClip).gotoAndStop(2);
						}
					}
					else{
						if((this._controlBar.volumeBtm as MovieClip).currentFrame == 2){
							(this._controlBar.volumeBtm as MovieClip).gotoAndStop(1);
						}						
					}

					dispatchEvent(new SkinEvent("CONTROL_BAR_VOLUME",param1));
				}
			}
		}

		public function set videoSeconds(s:Number):void{
			this._videoSeconds = s;
		}

		public function get videoSeconds():Number{
			return this._videoSeconds;
		}

		public function set progressBar(p:VideoProgressBar):void{
			this._progressBar = p;
		}

		public function get progressBar():VideoProgressBar{
			return this._progressBar;
		}
	}
}