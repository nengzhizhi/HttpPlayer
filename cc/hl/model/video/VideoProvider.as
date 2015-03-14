package cc.hl.model.video {
	import flash.geom.*;
    import flash.events.*;
    import flash.display.*;
	import flash.net.*;
	import flash.media.*;
	
	import cc.hl.model.video.base.*;
	import cc.hl.model.video.interfaces.*;
	
	import util.*;

	/**
	 *
	 * 视频提供类，用于从VideoInfo中读取视频流
	 * @author XiongYe
	 * @Time 
	 *
	**/
	public class VideoProvider extends Sprite implements IVideoProvider {
		
		protected var _video;//Video类或者是stage.stageVideos
		protected var _useStageVideo:Boolean;//是否使用stage video做加速
		protected var _videoInfo:VideoInfo;
		protected var _isInit:Boolean = false;
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		protected var _ratioType:int = 0;//当前video的长宽比
        protected var _volume:Number = 100;
        protected var _volumeBak:Number = 100;		
		protected var _playing:Boolean = true;


		public function VideoProvider(arg1:VideoInfo){
			this._videoInfo = arg1;

			this._useStageVideo = false;//默认使用normal video
			this._video = new Video();
			this._video.smoothing = true;
			addChild(this._video);

			GlobalData.STAGE.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);
		}

		protected function onNsReady(event:Event):void{
			if (!this._isInit) {
				this._isInit = true;
				this._video.attachNetStream(this.ns);
				dispatchEvent(new Event("VIDEO_PROVIDER_INIT"));
				this.resize(GlobalData.root.stage.stageWidth, GlobalData.root.stage.stageHeight);
			}
		}

		protected function onPlayEnd(event:Event):void{
			dispatchEvent(new Event("VIDEO_PROVIDER_PLAY_END"));
		}
		/**
		 *
		 * 当stage video 可用时切换video
		 *
		**/
		protected function onStageVideoAvailability(_arg1):void{
			$.jscall("console.log","hardware accelerate availability: "+_arg1.availability);
			this.switchVideo(_arg1.availability == "available");
		}

		/**
		 *
		 * 获取当前NetStream，如果是点播可能存在多个，直播只有一个。子类需要重载
		 * @return	NetStream
		 *
		**/
		protected function get ns():NetStream{
			return (null);
		}

		/**
		 *
		 * 根据硬件情况切换video类型
		 * @param	tryHardwareAccelerate:是否使用stage.stageVideos开启硬件加速
		 * @return	void
		 *
		**/
		protected function switchVideo(tryHardwareAccelerate:Boolean):void{
			if(tryHardwareAccelerate && (GlobalData.STAGE.stageVideos == null || GlobalData.STAGE.stageVideos.length == 0)){
				return;
			}

			if(this._useStageVideo != tryHardwareAccelerate){
				this._useStageVideo = tryHardwareAccelerate;

				if(tryHardwareAccelerate) {
					$.jscall("console.log","use stage video!");
					if(this._video && contains(this._video)){
						removeChild(this._video);
						this._video.clear();
						this._video = null;
					}
					this._video = GlobalData.STAGE.stageVideos[0];
					this._video.attachNetStream(this.ns);
				}
				else {
					$.jscall("console.log","use normal video!");
					this._video = new Video();
					this._video.smoothing = true;
					this._video.attachNetStream(this.ns);
					addChild(this._video);
				}

				this.resize(this._width, this._height);
			}
		}

		public function setVideoRatio(ratioType:int):void{
			this._ratioType = ratioType;

			if(this._video == null){
				return;
			}

			var _local2:int = ((((this._video.videoWidth) || (((("meta" in this.ns)) && (this.ns["meta"].width))))) || (this._width));
			var _local3:int = ((((this._video.videoHeight) || (((("meta" in this.ns)) && (this.ns["meta"].height))))) || (this._height));

			switch(ratioType){
				case 0:
					break;
				case 1:
					_local3 = ((_local2 * 3) / 4);
					break;
				case 2:
					_local3 = ((_local2 * 9) / 16);
					break;
				case 3:
					_local2 = this._width;
					_local3 = this._height;
					break;
			}

			var _local4:Rectangle = Util.getCenterRectangle(new Rectangle(0, 0, this._width, this._height), new Rectangle(0, 0, _local2, _local3));
			if ((this._video is StageVideo)){
				this._video.viewPort = _local4;
			} else {
				this._video.x = _local4.x;
				this._video.y = _local4.y;
				this._video.width = _local4.width;
				this._video.height = _local4.height;
			}
		}

		public function toggleSilent(arg1:Boolean):void{
			if(arg1){
				this._volumeBak = ((this._volume == 0) ? 50 : this._volume);
			}
		}

		/**
		 * 开始载入视频流，需要重载
		 * @param startTime:开始播放的时间，如果是直播值为0
		 */
		public function start(startTime:Number=0):void{
		}
		public function getVideoInfo():String{
			return (null);
		}
		public function resize(w:Number, h:Number):void{
			this._width = w;
			this._height = h;
			this.setVideoRatio(this._ratioType);
		}
		public function get playing():Boolean{
			return this._playing;
		}

		public function set playing(arg1:Boolean):void{
			if(arg1 != this._playing){
				this._playing = arg1;
			}

			if(this._playing){
				this.ns.resume();
			}
			else{
				this.ns.pause();
			}
		}

		public function get volume():Number{
			return this._volume;
		}
		public function set volume(arg1:Number):void{
			this._volume = arg1;
			this.ns.soundTransform = new SoundTransform(this._volume / 100);
		}

		public function get time():Number{
			return (0);
		}
		public function set time(_arg1:Number):void{
		}
		public function get streamTime():Number{
			return 0;
		}
		public function get buffPercent():Number{
			return 0;
		}
		public function get buffering():Boolean{
			return (false);
		}
		public function get videoLength():Number{
			return 0;
		}

	}
}