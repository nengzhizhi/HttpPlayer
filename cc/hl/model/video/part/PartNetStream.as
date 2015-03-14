/**
 * 点播视频源子码流的基类。
 * 主要用于控制子码流的载入，如果载入的同时需要直接播放，则将startPlay设为true，同时打开声音开关。
 * 否则只调用netstream.play(streamUrl)。
 *
 * 分段视频的buffer此处分两种，一种是分段视频bufferTime的小缓存池的状态，另外一种是整个分段视频的缓存状态。
 * 第一种是用来描述当前缓存状态的
 * 第二种是用来描述点播视频的下方进度条的
 *
**/

package cc.hl.model.video.part {
	
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    import flash.media.*;

    import cc.hl.model.video.base.*;
    import util.*;


	public class PartNetStream extends NetStream {

		protected var realStart:Number = NaN;
		protected var startPlay:Boolean = false; //是否开始播放，主要用于声音的开关
		protected var expectStartTime:Number = 0;
		protected var _meta:Object;
		protected var _buffering:Boolean = false; //分段视频的预分配缓存池是否已填满
		//protected var _bufferFinish:Boolean = false; // 分段视频全部载入
		protected var _streamFinish:Boolean = false;
		protected var _playFinish:Boolean = false;
		protected var _partVideoInfo:PartVideoInfo; //子码流信息
		protected var _ready:Boolean = false; // 码流是否全部载入
		protected var _bakSound:SoundTransform; // 用于开关声音时存储上次音量


		public function PartNetStream(arg1:NetConnection){
			this._bakSound = new SoundTransform(1);
			super(arg1);
			this.bufferTime = 1;
			this.client = {onMetaData:this.onMetaData}; //子类需要重载this.onMetaData
			this.addEventListener(NetStatusEvent.NET_STATUS, this.onStatus);
		}

		public function get ready():Boolean{
			return (this._ready);
		}

		public function get fullReady():Boolean{
			return (((((this._ready) && ((this.realStart == 0)))) && (this._streamFinish)));
		}

		public function get streamFinish():Boolean{
			return this._streamFinish;
		}

		public function get buffering():Boolean{
			return this._buffering;
		}

		public function get meta():Object{
			return (this._meta || ({}));
		}

		public function get partVideoInfo():PartVideoInfo{
			return this._partVideoInfo;
		}

		public function get duration():Number{
			return this._partVideoInfo.duration || this.meta.duration;
		}

		public function get streamSeconds():Number{
			if(this._ready){
				if(this.bytesLoaded > 0 && this.bytesLoaded == this.bytesTotal) {
					if (!this._streamFinish){
						this._streamFinish = true;
						dispatchEvent(new Event("NS_BUFFER_END"));
					}
					return this.duration;
				}

				if( this._meta && this._meta.keyframes) {
					return this.checkBufferWithMeta();
				}

				return ((this.duration * this.bytesLoaded) / this.bytesTotal);
			}
			return 0;
		}

		protected function onStatus(arg1:NetStatusEvent):void{
			switch (arg1.info.code){
				case "NetStream.Play.Start":
					super.soundTransform = new SoundTransform(0);
					this._playFinish = false;
					this.onNsReady();
					break;
				case "NetStream.Buffer.Full":
					this._buffering = false;
					break;
				case "NetStream.Buffer.Empty":
					if (this._playFinish){
						dispatchEvent(new Event("NS_PLAY_END"));
					}
					else {
						this._buffering = true;
					}
					break;
				case "NetStream.Play.Stop":
					if(this._ready){
						this._buffering = true;
					}
					break;
				case "NetStream.Seek.InvalidTime":
					super.seek(arg1.info.details);
					break;
				case "NetStream.Seek.Failed":
					break;
				case "NetStream.Play.StreamNotFound":
					this.close();
					dispatchEvent(new Event("NS_ERROR"));
					break;
			}
		}

		/**
		 * 载入视频流
		 * @param arg1	子码流对应信息
		 * @param arg2	是否开始播放
		 * @param arg3	播放的开始时间
		 * @return void
		**/
		public function load(arg1:PartVideoInfo, arg2:Boolean=false, arg3:Number=0):void{
			this.close();//关闭当前流
			this._partVideoInfo = arg1;
			this.startPlay = arg2;
			this.expectStartTime = arg3;

			$.jscall("console.log", "Part " + arg1.index + "start load");
			play(arg1.url);
		}

		/**
		 * 关闭当前流，并重置某些标记值
		 * @param null
		 * @return void
		**/

		override public function close():void{
			super.close();
			this.reset();
		}

		protected function reset():void{
			this._ready = false;
			this._streamFinish = false;
			this._buffering = true;
		}

		/**
		 * 码流全部载入成功
		**/
		protected function onNsReady():void{
			if(!this._ready){
				this._buffering = false;
				this._ready = true;
				
				if(this.startPlay){
					super.soundTransform = this._bakSound;
				}
				else{
					pause();
				}
				dispatchEvent(new Event("NS_READY"));
			}
		}

		/**
		 * 设置音量
		**/
		override public function set soundTransform(arg1:SoundTransform):void{
			this._bakSound = arg1;

			if(this.ready){
				super.soundTransform = arg1;
			}
		}

		public function canSearchByte():Boolean{
			return this._ready || this._meta;
		}

		public function canSeek(seekTime:Number):Boolean{
			return ((this._ready) && (this.streamSeconds > seekTime) && (this.realStart <= seekTime));
		}

		/**
		 * 需要重载
		**/

		public function getRealSeekTime(seekTime:Number):Number{
			return seekTime;
		}

		protected function checkBufferWithMeta():Number{
			throw (new Error((this.toString() + " need override 'checkBufferWithMeta'!")));
		}
		public function searchByte(_arg1:Number):int{
			throw (new Error((this.toString() + " need override 'searchByte'!")));
		}		
		protected function onMetaData(_arg1:Object):void{
			throw (new Error((this.toString() + " need override 'onMetaData'!")));
		}

	}
}