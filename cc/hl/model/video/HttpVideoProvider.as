package cc.hl.model.video {

	/**
	 * 提供基于Http协议的点播视频源
	 * @author
	 * @Time
	 */

    import flash.events.*;
    import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import cc.hl.model.video.base.*;
	import cc.hl.model.video.part.*;

	public class HttpVideoProvider extends VideoProvider {
		
		private var nc:NetConnection;
		private var nss:Vector.<PartNetStream>;
		private var currentPlay:int = -1; //当前正在播放的partNetStream的索引号
		private var currentLoad:int = -1; //当前载入的partNetStream的索引号
		private var playOffset:Number = 0;
        private var loadOffset:Number = 0;
		private var checkTimer:Timer;

		public function HttpVideoProvider(arg1:VideoInfo){
			super(arg1);
			
			this.nc = new NetConnection();
			this.nc.connect(null);
			this.nss = new Vector.<PartNetStream>(_videoInfo.count);

			for(var i:int = 0; i < _videoInfo.count; i++){
				if( _videoInfo.fileType == "mp4"){
					//this.nss[i] = new MP4PartNetStream(this.nc);
				}
				else{
					this.nss[i] = new FLVPartNetStream(this.nc);
				}
				this.nss[i].addEventListener("NS_READY", onNsReady);
			}

			this.checkTimer = new Timer(5000);
			this.checkTimer.addEventListener(TimerEvent.TIMER, this.checkLoad);

		}

		/**
		 * 重载
		 * 获取当前NetStream的函数，直播只有一个，点播有多个
		**/
		override protected function get ns():NetStream{
			return (this.nss[this.currentPlay]);
		}

		override protected function onPlayEnd(event:Event):void{
			var nextIndex = this.currentPlay + 1;
			if(nextIndex == this._videoInfo .count){
				dispatchEvent(new Event("VIDEOPROVIDER_PLAY_END"));
			} else {
				this.switchNs(nextIndex);
			}
		}

		/**
		 * 开始播放视频源
		 * @param	startTime	点播开始的时间
		 */
		override public function start(startTime:Number=0):void{
			this.time = startTime;
			this.checkTimer.start();
		}

		/**
		 * 载入指定的partNetStream
		 * @param index		partNetStream对的索引号
		 * @param startTime	载入的起始时间
		 * @param play		是否立即播放
		 * @return 空
		**/
		private function load(index:int, startTime:Number=0, play:Boolean=false):void{

			if(index >=0 && index < this._videoInfo.count){
				if(this.currentLoad != index){
					if(this.currentLoad != -1){ //当前有正在载入的partNetStream停止载入
						if(!this.nss[this.currentLoad].streamFinish){
							this.nss[this.currentLoad].close();
						}
					}

					for(var i:int = 1; i <= index; i++){
						this.loadOffset = this.loadOffset + (this._videoInfo.vtimes[i] / 1000);
					}
					this.currentLoad = index;
				}

				var nsTmp = this.nss[this.currentLoad];

				if(startTime <= 1){
					this._videoInfo.getPartVideoInfo(function (arg1:PartVideoInfo):void{
						nsTmp.load(arg1, play, startTime);
					}, index, 0);
				}
				else{
					if(this._videoInfo.useSecond){ //根据时间查找
						this._videoInfo.getPartVideoInfo(function (arg1:PartVideoInfo):void{
							nsTmp.load(arg1, play, startTime);
						}, index, startTime);
					}
					else{ // 根据文件位置查找
						if (nsTmp.canSearchByte()) {

						}
						else{

						}
					}
				}
			}
		}

		/**
		 * 切换PartNetStream，并定位时间
		**/
		private function switchNs(index:int, startTime:Number=0):void{
			if(index >= this._videoInfo.count){
				return;
			}

			//trace("currentPlay = " + this.currentPlay);
			//trace("index = " + index);

			if(this.currentPlay != index){
				//停止当前正在播放码流
				if(this.currentPlay != -1){
					if (this.nss[this.currentPlay].fullReady){
						this.nss[this.currentPlay].seek(0);
					}
					this.nss[this.currentPlay].pause();
				}

				this.currentPlay = index;

				this.playOffset = 0;
				for(var i:int = 1;i <= index; i++){
					this.playOffset = this.playOffset + (this._videoInfo.vtimes[i] / 1000);
				}

				//trace("playOffset = " + this.playOffset);

				this._video.attachNetStream(this.nss[index]);
				volume = this._volume;
			}

			var partNetStream:PartNetStream = this.nss[index];
			startTime = partNetStream.getRealSeekTime(startTime);

			if(this._videoInfo.disableSeekJump){
				if(partNetStream.ready){ //全部载入成功可以自由缓存
					partNetStream.seek(startTime);
					if(this._playing){
						partNetStream.resume();
					}
				} else { //否则从头开始播放
					this.load(index, 0, _playing);
				}
			} else {
				if(partNetStream.canSeek(startTime)){
					partNetStream.seek(startTime);

					if(this._playing){
						partNetStream.resume();
					}
				} else {
					this.load(index, startTime, this._playing);
				}
			}
		}


		/**
		 *  根据缓存池状态判断是否载入下一段流
		 *
		**/
		private function checkLoad(arg1:TimerEvent):void{
			if( this._isInit){
				this.clearMemory();
				//当前分段视频已载入，并且缓存池有空间或者是当前载入的就是当前播放的分段视频。
				if( this.nss[this.currentLoad].streamFinish 
					&& ( System.totalMemory < GlobalData.MAX_USE_MEMORY_ARRAY[PlayerConfig.getInstance().max_use_memory_level]
						 || this.currentLoad == this.currentPlay)){
						this.load(this.currentLoad + 1);
				}
			}
		}

		private function clearMemory():void {
			var temp:int;
			var indexArray:Array;
			var useMemoryLevel = GlobalData.MAX_USE_MEMORY_ARRAY[PlayerConfig.getInstance().max_use_memory_level];
			if(System.totalMemory > useMemoryLevel){
				indexArray = [];
				var i:int = 0;
				for( i = 0; i < this._videoInfo.count; i++){
					if(this.nss[i].ready && (i != this.currentLoad) && (i != this.currentPlay) && (i != this.currentPlay + 1) && (i != this.currentPlay - 1)){
						indexArray.push(i);
					}
				}

				indexArray.sort(this.comparePart);
				for(i = 0; i < indexArray.length; i++){
					temp = indexArray[i];
					if(this.currentPlay > temp || this.currentLoad < temp){
						this.nss[temp].close();
						if(System.totalMemory < useMemoryLevel){
							break;
						}
					}
				}
			}
		}

		private function comparePart(arg1:int, arg2:int):int {
			if(this.nss[arg1].fullReady != this.nss[arg2].fullReady) {
				//根据分段视频的载入情况做排序，未载入完成的优先释放
				if(!this.nss[arg1].fullReady){
					return (-1);
				}
				return 1;
			}

			if(arg1 < arg2){
				if(arg1 > this.currentPlay){
					return 1;
				}
				return (-1);
			}

			if(arg2 > this.currentPlay){
				return (-1);
			}
			return 1;
		}

		override public function get buffPercent():Number{
			if(this.nss && this.nss[this.currentPlay]){
				//bufferLength 当前在缓冲区中的数据的数量，以秒为单位。
				//bufferTime 通过 setBufferTime() 赋给缓冲区的秒数。
				return this.nss[this.currentPlay].bufferLength / this.nss[this.currentPlay].bufferTime;
			}
			return 0;
		}
		override public function get streamTime():Number{
			if (this.currentPlay > this.currentLoad) {
				return this.playOffset + this.nss[this.currentPlay].streamSeconds;
			}
			return this.loadOffset + this.nss[this.currentLoad].streamSeconds;
		}
		override public function get buffering():Boolean{
			return (this.nss[this.currentPlay].buffering);
		}
		override public function get time():Number{
			return ((this.playOffset + this.nss[this.currentPlay].time));
		}

		override public function set time(t:Number):void{
			var pos:Array;
			if(this._videoInfo.count == 1){
				this.switchNs(0, int(t));
			}
			else{
				pos = this._videoInfo.getIndexOfPosition(int(t));
				this.switchNs(pos[0], pos[1]);
			}
		}

		override public function get videoLength():Number{
			return (this._videoInfo.totalTime || this.nss[this.currentPlay].duration);
		}
	}
}