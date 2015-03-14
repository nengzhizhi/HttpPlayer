package cc.hl.model.video {

    import flash.events.*;
    import flash.net.*;

    import util.*;
	import cc.hl.model.video.base.*;
	
	public class LiveVideoProvider extends VideoProvider {

		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _meta:Object;
		private var _buffering:Boolean;

		public function LiveVideoProvider(_videoInfo:VideoInfo){
			super(_videoInfo);
		}

		protected function onNetStatus(event:NetStatusEvent):void{
			switch (event.info.code){
				case "NetStream.Play.Start":
					onNsReady(null);
					break;
				case "NetStream.Buffer.Full":
					this._buffering = false;
					break;
				case "NetStream.Buffer.Empty":
					this._buffering = true;
					break;
				case "NetStream.Play.Stop":
					this.close();
					$.jscall("console.log", "直播被断开");
					break;
				case "NetStream.Play.StreamNotFound":
					this.close();
					$.jscall("console.log", "直播流未找到");
					break;
			}
		}

		override protected function get ns():NetStream{
			return this._ns;
		}

		override public function start(startTime:Number=0):void{
			var playUrl:String = this._videoInfo.urlArray[0];
			var index:* = 0;
			var rtmp:* = null;
			var play:* = null;

			this.close();
			if(playUrl.indexOf("rtmp") == 0){
				index = playUrl.lastIndexOf("/");
				rtmp = playUrl.substring(0, index);
				play = playUrl.substring((index + 1));

				this._nc = new NetConnection();
				this._nc.client = {};
				this._nc.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent):void{
					switch (event.info.code){
						case "NetConnection.Connect.Success":
							_ns = new NetStream(_nc);
							_ns.client = {onMetaData:onMetaData};
							_ns.bufferTime = 0;
							_ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
							_ns.play(play);
							_video.attachNetStream(_ns);
							break;
					}
				});
				this._nc.connect(rtmp);

			}
			else{
				this._nc = new NetConnection();
				this._nc.connect(null);
				this._ns = new NetStream(this._nc);
				this._ns.client = {onMetaData:this.onMetaData};
				this._ns.bufferTime = 1;
				this._ns.addEventListener(NetStatusEvent.NET_STATUS, this.onNetStatus);
				this._ns.play(playUrl);
				this._video.attachNetStream(this._ns);
			}
			this._playing = true;
		}

		override public function get buffPercent():Number{
			return this.ns.bufferLength / this.ns.bufferTime;
		}

		override public function get streamTime():Number{
			return 0;
		}

		override public function get buffering():Boolean{
			return this._buffering;
		}

		override public function getVideoInfo():String{
			var info = "";
			return info;
		}

		override public function get time():Number{
			return this.ns.time;
		}

		override public function set time(t:Number):void{}

		override public function get videoLength():Number{
			return 0;
		}

		protected function onMetaData(obj:Object):void{
			this._meta = obj;
		}

		override public function set playing(arg1:Boolean):void{
			if(arg1 != this._playing){
				this._playing = arg1;

				if(this._playing){
					this._videoInfo.refresh();
					this._videoInfo.addEventListener(Event.COMPLETE, function():void{
						_videoInfo.removeEventListener(Event.COMPLETE, arguments.callee);
						start();
					});
				}
				else{
					this.close();
				}
			}
		}

		protected function close():void{
			if(this._ns){
				this._ns.close();
			}

			if(this._nc){
				this._nc.close();
			}
		}

	}

}