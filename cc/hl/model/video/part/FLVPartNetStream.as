package cc.hl.model.video.part {
	
	import flash.events.*;
    import flash.net.*;
	import flash.utils.*;
	
	import cc.hl.model.video.base.*;
	import util.*;
	
	public class FLVPartNetStream extends PartNetStream{

		protected var checkStartTimeTimer:Timer;
		protected var _startOffset:Number = 0; // 开始时间，之前码流时间和
		protected var _filesize:Number = 0;
		protected var _lastPlayTime:Number = 0; //load前记录当前播放时间，用于判断是否发生跳转

		public function FLVPartNetStream(arg1:NetConnection){
			super(arg1);
			this.checkStartTimeTimer = new Timer(10);
			this.checkStartTimeTimer.addEventListener(TimerEvent.TIMER, this.onCheckStartTime);			
		}

		protected function onCheckStartTime(_arg1:TimerEvent):void{
			//发生跳转
			if ((((super.time > 0.1)) && (!((super.time == this._lastPlayTime))))){
				this.checkStartTimeTimer.reset();
				realStart = (super.time - this._startOffset);
				realStart = (((realStart > 1)) ? realStart : 0);
				super.onNsReady();
			};
		}

		/**
		 * 
		**/
		override public function get time():Number{
			if (!isNaN(realStart)){
				return ((super.time - this._startOffset));
			};
			return (expectStartTime);
		}

		/**
		 * 定位到已缓存的时刻
		 * @param arg1	需要定位的时间点
		 * @return void
		**/
		override public function seek(arg1:Number):void{
			var local2:Number = arg1 + this._startOffset;
			var local3:Number = streamSeconds + this._startOffset;

			local2 = local2 < local3 ? local2 : local3;

			if (Math.abs(local2 - super.time) > 1){
				super.seek(local2);
			}
		}

		/**
		 * 从meta中读取最接近的关键帧的时间
		 * 读时间
		 * @param arg1	需要seek的时间
		 * @return 最接近的关键帧的时间，可以从这个时间点开始load stream
		**/
		override public function getRealSeekTime(arg1:Number):Number{
			var local2:int;

			if(this._meta && this._meta.keyframes){
				local2 = Util.bsearch(this._meta.keyframes.times, arg1 + this._startOffset);
				arg1 = this._meta.keyframes.times[local2 - 1] - this._startOffset;
			}

			return arg1;
		}

		override protected function onMetaData(arg1:Object):void{
			var local2:Object;
			var local3:Object;
			this._meta = arg1;

			if(arg1.seekpoints){
				local2 = {
					times:[],
					filepositions:[]
				}

				for each (local3 in arg1.seekpoints) {
					local2.times.push(local3.time);
					local2.filepositions.push(local3.offset);
				}
				arg1.keyframes = local2;
			}

			if(this._meta.keyframes){
				if(this._meta.keyframes.times[1] > 30){
					this._startOffset = this._meta.keyframes.times[1];
				}

				this._filesize = (this._meta.filesize) || (this._meta.keyframes.filepositions.slice(-1)[0]);
			}
		}

		override public function load(_arg1:PartVideoInfo, _arg2:Boolean=false, _arg3:Number=0):void{
			this._lastPlayTime = super.time;
			super.load(_arg1, _arg2, _arg3);
			if (_arg3 > 0){
				this.checkStartTimeTimer.start();
			};
		}

		/**
		 * 根据时间定位到最接近的关键帧位置
		 * 读位置
		 * @param timeToSearch	要定位的时间
		 * @return 邻近关键帧的索引号
		**/
		override public function searchByte(timeToSearch:Number):int{
			var index:int;

			if(canSearchByte()){
				if(this._meta.keyframes){
					index = Util.bsearch(this._meta.keyframes.times, timeToSearch + this._startOffset);
					if(index != -1){
						return this._meta.keyframes.filepositions[(index - 1)];
					}
				}
			}

			return 0;
		}

        override protected function checkBufferWithMeta():Number{
            var _local1:int = Util.bsearch(_meta.keyframes.filepositions, (bytesLoaded + (this._filesize - this.bytesTotal)));
            return ((_meta.keyframes.times[(_local1 - 1)] - this._startOffset));
        }		
		override protected function onNsReady():void{
			if ((expectStartTime == 0) && !ready){
				realStart = 0;
				super.onNsReady();
			}
		}
	}
}