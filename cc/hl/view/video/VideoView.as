package cc.hl.view.video {

	import flash.display.*;
	import flash.media.*;
	import flash.utils.*;
	import flash.events.*;
	
	import cc.hl.model.video.base.*;
	import cc.hl.model.video.platform.*;
	import cc.hl.model.video.*;
	
	public class VideoView extends Sprite {
		private var _provider:VideoProvider;
		private var _videoInfo:VideoInfo;
		private var _sendTimer:Timer;


		public function VideoView(){
			super();
		}

		public function startVideo(vid:String, type:String, startTime:Number=0):void{
			switch (type){
				case VideoType.YOUKU:
					this._videoInfo = new YoukuVideoInfo(vid);
					break;
				default:
					break;
			}
			this._videoInfo.load();

			this._videoInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				var arguments:* = arguments;
				_videoInfo.removeEventListener(Event.COMPLETE, arguments.callee);

				if(_videoInfo.fileType == "flv" || _videoInfo.fileType == "mp4"){
					_provider = new HttpVideoProvider(_videoInfo);
				}

				_provider.start(startTime);
				_provider.addEventListener("VIDEO_PROVIDER_INIT", function():void{
					dispatchEvent(new Event("VIDEO_PROVIDER_INIT"));
				});

				_provider.addEventListener("VIDEO_PROVIDER_PLAY_END", function():void{

				});

				addChild(_provider);

				_sendTimer = new Timer(500);
				_sendTimer.addEventListener(TimerEvent.TIMER, sendLoop);
				_sendTimer.start();
			});
		}

		private function sendLoop(event:TimerEvent=null):void{
			dispatchEvent(new Event("VIDEO_PROVIDER_UPDATE"));
		}

		public function resize(w:Number, h:Number):void{
			this._provider.resize(w, h);
		}

		public function get playing():Boolean{
			return this._provider.playing;
		}

		public function set playing(state:Boolean):void{
			this._provider.playing = state;
		}

		public function get volume():Number{
			return this._provider.volume;
		}

		public function set volume(v:Number):void{
			this._provider.volume = v;
		}

		public function get time():Number{
			return ((this._provider) ? this._provider.time : 0);
		}

		public function set time(t:Number):void{
			this._provider.time = t;
		}

		public function get provider():VideoProvider{
			return this._provider;
		}
	}
}