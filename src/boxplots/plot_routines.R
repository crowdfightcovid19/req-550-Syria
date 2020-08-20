#***************************************
#plot_routines.R
#***************************************
#
#
#author = Eduard Campillo-Funollet
#email = e.campillo-funollet@sussex.ac.uk
#date = 30th July 2020
#description = Plot routines
#usage = Aux. routines for plotting. Not standalone.


currentDir <- getwd()
setwd("/home/ecam/workbench/req-550-Syria/src")

library(ggplot2)
library(grid)
library(gridExtra)

fymin.q <- function(z){ return(quantile(z,0.25))} 
fymax.q <- function(z){ return(quantile(z,0.75))} 
fymin.sd <- function(z){ return(mean(z)-sd(z))} 
fymax.sd <- function(z){ return(mean(z)+sd(z))} 
fymin.se <- function(z){ return(mean(z)-sd(z)/sqrt(length(z[!is.na(z)])))} 
fymax.se <- function(z){ return(mean(z)+sd(z)/sqrt(length(z[!is.na(z)])))} 



axis.text.size = 30
axis.title.size = 35
legend.title.size = 35
legend.text.size = 32

def_color_scale <- c("T" = "#619CFF","E" = "#FFB54D","S" = "#00BA38")

#By Alberto
extract_subtable_output_summaries = function(df.out,params.df){
  Ncomp = dim(params.df)[1]
  df.sub=data.frame()
  for(i in 1:Ncomp){
    contacts.var=as.character(params.df$contacts[i])
    PopSize.var=paste("PopSize",params.df$Npop[i],sep="")
    Isolate.var=paste("Isolate",params.df$Isolate[i],sep="")
    Limit.var=paste("Limit",params.df$Limit[i],sep="")
    Onset.var=paste("Onset",params.df$Onset[i],sep="")
    Fate.var=paste("Fate",params.df$Fate[i],sep="")
    Tcheck.var=paste("Tcheck",params.df$Tcheck[i],sep="")
    lock.var=paste("lock",params.df$lock[i],sep="")
    self.var=paste("self",params.df$self[i],sep="")
    
    df.tmp=subset(df.out, contacts==contacts.var &  Isolate==Isolate.var & 
                    Onset == Onset.var & Limit==Limit.var & Fate==Fate.var & Tcheck==Tcheck.var &
                    PopSize==PopSize.var & lock==lock.var & self==self.var)
    
    df.sub=rbind(df.sub,df.tmp)
  }
  return(df.sub)
}

do_ribbon_plot <- function(df,fn,varX,xlabel,ylabel,fymin,fymax,fun,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE){
    dodge <- position_dodge(width = 0.9)
    gg <- ggplot(data=df)+
            geom_point(position=position_jitterdodge(dodge.width=0.9),aes_string(x=varX,y=fn,colour="group",group="group"),alpha=.1)+
            stat_summary(geom="ribbon",fun.min=fymin,fun.max=fymax,aes_string(x=varX,y=fn,group="group",fill="group"),position=dodge,alpha=.5)+
            stat_summary(geom="line",fun=fun,aes_string(x=varX,y=fn,group="group",colour="group"),position=dodge,)+
            xlab(xlabel)+
            ylab(ylabel)+
            scale_x_discrete(labels=scale_x_labels)+
            #scale_fill_discrete(name=group_name,labels=scale_fill_labels)+
            #scale_color_discrete(name=group_name,labels=scale_fill_labels)+
            scale_fill_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            scale_color_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            theme(  legend.text = element_text(size=legend.text.size),
                    legend.title = element_text(size=legend.title.size),
                    axis.text = element_text(size=axis.text.size), 
                    axis.title = element_text(size=axis.title.size),
                    panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "lightgrey"), 
                    panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "lightgrey"),
                    panel.background = element_rect(fill = "white", colour = "black", linetype = "solid"))

    if(nolegend)
        gg <- gg + theme(legend.position = "none")

    return(gg)
}

do_box_plot<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE,fun="mean",addmean=FALSE){
    dodge <- position_dodge(width = 0.9)
    gg <- ggplot(data=df)+
            geom_point(position=position_jitterdodge(dodge.width=0.9),aes_string(x=varX,y=fn,colour="group",group="group"),alpha=.075)

    if(line){
        gg <- gg + stat_summary(geom="line",fun=fun,aes_string(x=varX,y=fn,group="group",colour="group"),position=dodge,size=2)
    }
        gg <- gg + geom_boxplot(aes_string(x=varX,y=fn,fill="group"),position=dodge)+
            xlab(xlabel)+
            ylab(ylabel)+
            scale_x_discrete(labels=scale_x_labels)+
#            scale_fill_discrete(name=group_name,labels=scale_fill_labels)+
#            scale_color_discrete(name=group_name,labels=scale_fill_labels)+
            scale_fill_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            scale_color_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            theme(  legend.text = element_text(size=legend.text.size),
                    legend.title = element_text(size=legend.title.size),
                    axis.text = element_text(size=axis.text.size), 
                    axis.title = element_text(size=axis.title.size),
                    panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "lightgrey"), 
                    panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "lightgrey"),
                    panel.background = element_rect(fill = "white", colour = "black", linetype = "solid"))

    if(addmean)
        gg <- gg + stat_summary(geom="point",fun="mean",aes_string(x=varX,y=fn,group="group"),color="black",shape=20,size=4,position=dodge)

    if(nolegend)
        gg <- gg + theme(legend.position = "none")

    return(gg)

}

do_vio_plot<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE,fun="mean"){
    dodge <- position_dodge(width = 0.9)
    gg <- ggplot(data=df)

    if(line){
        gg <- gg + stat_summary(geom="line",fun=fun,aes_string(x=varX,y=fn,group="group",colour="group"),position=dodge,size=2)
    }
        gg <- gg + geom_violin(aes_string(x=varX,y=fn,fill="group"),position=dodge)+
            xlab(xlabel)+
            ylab(ylabel)+
            scale_x_discrete(labels=scale_x_labels)+
            scale_fill_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            scale_color_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            theme(  legend.text = element_text(size=legend.text.size),
                    legend.title = element_text(size=legend.title.size),
                    axis.text = element_text(size=axis.text.size), 
                    axis.title = element_text(size=axis.title.size),
                    panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "lightgrey"), 
                    panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "lightgrey"),
                    panel.background = element_rect(fill = "white", colour = "black", linetype = "solid"))

    if(nolegend)
        gg <- gg + theme(legend.position = "none")

    return(gg)

}

do_line_plot<- function(df,fn,varX,xlabel,ylabel,fun,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE,alpha=.75){
    dodge <- position_dodge(width = 0.3)
    gg <- ggplot(data=df)+
            stat_summary(geom="line",fun=fun,aes_string(x=varX,y=fn,group="group",colour="group"),size=2,alpha=alpha,position=dodge)+
            stat_summary(geom="point",fun=fun,aes_string(x=varX,y=fn,group="group",colour="group"),size=4,alpha=alpha,position=dodge)+
            xlab(xlabel)+
            ylab(ylabel)+
            scale_x_discrete(labels=scale_x_labels)+
#            scale_fill_discrete(name=group_name,labels=scale_fill_labels)+
#            scale_color_discrete(name=group_name,labels=scale_fill_labels)+
            scale_fill_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+
            scale_color_manual(name=group_name,labels=scale_fill_labels,values=def_color_scale)+

            theme(  legend.position = "top",
                    legend.text = element_text(size=legend.text.size),
                    legend.title = element_blank(),
                    axis.text = element_text(size=axis.text.size), 
                    axis.title = element_text(size=axis.title.size),
                    panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "lightgrey"), 
                    panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "lightgrey"),
                    panel.background = element_rect(fill = "white", colour = "black", linetype = "solid"))

    if(nolegend)
        gg <- gg + theme(legend.position = "none")

    return(gg)

}

#Wrappers:
do_ribbon_quartile <- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE){
    return(do_ribbon_plot(df,fn,varX,xlabel,ylabel,fymin.q,fymax.q,"median",scale_x_labels,scale_fill_labels,group_name,nolegend));
}

do_ribbon_sd <- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE){
    return(do_ribbon_plot(df,fn,varX,xlabel,ylabel,fymin.sd,fymax.sd,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend));
}

do_ribbon_se <- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,nolegend=FALSE){
    return(do_ribbon_plot(df,fn,varX,xlabel,ylabel,fymin.se,fymax.se,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend));
}

do_box_plot_mean<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE){
    return(do_box_plot(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=TRUE,nolegend=nolegend,fun="mean"))
}

do_box_plot_mean_dot<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE){
    return(do_box_plot(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=TRUE,nolegend=nolegend,fun="mean",addmean=TRUE))
}



do_box_plot_median<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE){
    return(do_box_plot(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=TRUE,nolegend=nolegend,fun="median"))
}

do_vio_plot_mean<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE){
    return(do_vio_plot(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=TRUE,nolegend=nolegend,fun="mean"))
}

do_vio_plot_median<- function(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=FALSE,nolegend=FALSE){
    return(do_vio_plot(df,fn,varX,xlabel,ylabel,scale_x_labels,scale_fill_labels,group_name,line=TRUE,nolegend=nolegend,fun="median"))
}



#do_ribbon_plot(df,fn,varX,xlabel,ylabel,fymin.sd,fymax.sd,"median",scale_x_labels,scale_fill_labels,group_name)
#do_ribbon_plot(df,fn,varX,xlabel,ylabel,fymin.sd,fymax.sd,"mean",scale_x_labels,scale_fill_labels,group_name)
#do_box_plot(df,fn,varX,xlabel,ylabel,"median",scale_x_labels,scale_fill_labels,group_name)
#do_box_plot(df,fn,varX,xlabel,ylabel,"median",scale_x_labels,scale_fill_labels,group_name,line=TRUE)
#do_vio_plot(df,fn,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name)
#do_vio_plot(df,fn,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,line=TRUE)
#do_line_plot(df,fn,varX,xlabel,ylabel,"mean",scale_x_labels,scale_fill_labels,group_name,nolegend=TRUE)


setwd(currentDir) #Let's finish where we started.
