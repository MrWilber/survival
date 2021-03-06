### R code from vignette source 'survival.Rnw'

###################################################
### code chunk number 1: survival.Rnw:39-83
###################################################
options(continue="  ", width=70)
options(SweaveHooks=list(fig=function() par(mar=c(4.1, 4.1, .3, 1.1))))
pdf.options(pointsize=10) #text in graph about the same as regular text
options(contrasts=c("contr.treatment", "contr.poly")) #ensure default
library("survival")
palette(c("#000000", "#D95F02", "#1B9E77", "#7570B3", "#E7298A", "#66A61E"))

# These functions are used in the document, but not discussed until the end
crisk <- function(what, horizontal = TRUE, ...) {
    nstate <- length(what)
    connect <- matrix(0, nstate, nstate,
                      dimnames=list(what, what))
    connect[1,-1] <- 1  # an arrow from state 1 to each of the others
    if (horizontal) statefig(c(1, nstate-1),  connect, ...)
    else statefig(matrix(c(1, nstate-1), ncol=1), connect, ...)
}

state3 <- function(what, horizontal=TRUE, ...) {
    if (length(what) != 3) stop("Should be 3 states")
    connect <- matrix(c(0,0,0, 1,0,0, 1,1,0), 3,3,
                      dimnames=list(what, what))
    if (horizontal) statefig(1:2, connect, ...)
    else statefig(matrix(1:2, ncol=1), connect, ...)
}

state4 <- function() {
    sname <- c("Entry", "CR", "Transplant", "Transplant")
    layout <- cbind(c(1/2, 3/4, 1/4, 3/4),
                    c(5/6, 1/2, 1/2, 1/6))
    connect <- matrix(0,4,4, dimnames=list(sname, sname))
    connect[1, 2:3] <- 1
    connect[2,4] <- 1
    statefig(layout, connect)
}

state5 <- function(what, ...) {
    sname <- c("Entry", "CR", "Tx", "Rel", "Death")
    connect <- matrix(0, 5, 5, dimnames=list(sname, sname))
    connect[1, -1] <- c(1,1,1, 1.4)
    connect[2, 3:5] <- c(1, 1.4, 1)
    connect[3, c(2,4,5)] <- 1
    connect[4, c(3,5)]  <- 1
    statefig(matrix(c(1,3,1)), connect, cex=.8,...)
}


###################################################
### code chunk number 2: states
###################################################
getOption("SweaveHooks")[["fig"]]()
oldpar <- par(mar=c(.1, .1, .1, .1), mfrow=c(2,2))
sname1 <- c("Alive", "Dead")
cmat1 <- matrix(c(0,0,1,0), nrow=2, 
                dimnames=list(sname1, sname1))
statefig(c(1,1), cmat1)

sname2 <- c("0", "1", "2", "...")
cmat2 <- matrix(0, 4,4, dimnames= list(sname2, sname2))
cmat2[1,2] <- cmat2[2,3] <- cmat2[3,4] <- 1
statefig(c(1,1,1,1), cmat2, bcol=c(1,1,1,0))

sname3 <- c("Entry", "Transplant", "Withdrawal", "Death")
cmat3 <- matrix(0, 4,4, dimnames=list(sname3, sname3))
cmat3[1, -1] <- 1
statefig(c(1,3), cmat3)

sname4 <- c("Health", "Illness", "Death")
cmat4 <- matrix(0, 3, 3, dimnames = list(sname4, sname4))
cmat4[1,2] <- cmat4[2,1] <- cmat4[-3, 3] <- 1
statefig(c(1,2), cmat4, offset=.03)

par(oldpar)


###################################################
### code chunk number 3: survfit1
###################################################
fit1 <- survfit(Surv(futime, fustat) ~ resid.ds, data=ovarian)
print(fit1, rmean= 730)

summary(fit1, times= (0:4)*182.5, scale=365)


###################################################
### code chunk number 4: survfit2
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(fit1, col=1:2, xscale=365.25, lwd=2, mark.time=TRUE,
     xlab="Years since study entry", ylab="Survival")
legend(750, .9, c("No residual disease", "Residual disease"), 
       col=1:2, lwd=2, bty='n')


###################################################
### code chunk number 5: survfit3
###################################################
getOption("SweaveHooks")[["fig"]]()
fit2 <- survfit(Surv(time, status) ~  sex + ph.ecog, data=lung)
fit2
plot(fit2[1:3], lty=1:3, lwd=2, xscale=365.25, fun='event',
       xlab="Years after enrollment", ylab="Survival")
legend(550, .6, paste("Performance Score", 0:2, sep=' ='), 
       lty=1:3, lwd=2, bty='n')
text(400, .95, "Males", cex=2)


###################################################
### code chunk number 6: survival.Rnw:572-574
###################################################
data.frame(id=rep(392,3), time1=c(0, 258, 328), time2=c(258, 328, 377),
           status=c(1,1,0))


###################################################
### code chunk number 7: survival4
###################################################
vdata <- with(valveSeat, data.frame(id=id, time2=time, status=status))
first <- !duplicated(vdata$id)
vdata$time1 <- ifelse(first, 0,  c(0, vdata$time[-nrow(vdata)]))
double <- which(vdata$time1 == vdata$time2)
vdata$time1[double] <- vdata$time1[double] -.01
vdata$time2[double-1] <- vdata$time1[double]
vdata[1:7, c("id", "time1", "time2", "status")]
survcheck(Surv(time1, time2, status) ~ 1, id=id, data=vdata)


###################################################
### code chunk number 8: survival5
###################################################
getOption("SweaveHooks")[["fig"]]()
vfit <- survfit(Surv(time1, time2, status) ~1, data=vdata, id=id)
plot(vfit, cumhaz=TRUE, xlab="Days", ylab="Cumulative hazard")


###################################################
### code chunk number 9: cgd1d
###################################################
getOption("SweaveHooks")[["fig"]]()
cgdsurv <- survfit(Surv(tstart, tstop, status) ~ treat, cgd, id=id)
plot(cgdsurv, cumhaz=TRUE, col=1:2, conf.times=c(100, 200, 300, 400),
     xlab="Days since randomization", ylab="Cumulative hazard")


###################################################
### code chunk number 10: simple1
###################################################
crdata <- data.frame(time= c(1:8, 6:8),
                     endpoint=factor(c(1,1,2,0,1,1,3,0,2,3,0),
                                     labels=c("censor", "a", "b", "c")),
                     istate=rep("entry", 11),
                     id= LETTERS[1:11])
tfit  <- survfit(Surv(time, endpoint) ~ 1, data=crdata, id=id, istate=istate)
dim(tfit)
summary(tfit)


###################################################
### code chunk number 11: survival.Rnw:692-693
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(tfit, col=1:4, lty=1:4, lwd=2, ylab="Probability in state")


###################################################
### code chunk number 12: survival.Rnw:706-708
###################################################
dim(tfit)
tfit$states


###################################################
### code chunk number 13: mgus1
###################################################
mgus2[55:59, -(4:7)]


###################################################
### code chunk number 14: mgus2
###################################################
getOption("SweaveHooks")[["fig"]]()
event <- with(mgus2, ifelse(pstat==1, 1, 2*death))
event <- factor(event, 0:2, c("censored", "progression", "death"))
etime <- with(mgus2, ifelse(pstat==1, ptime, futime))
crfit <- survfit(Surv(etime, event) ~ sex, mgus2)
crfit

plot(crfit, col=1:2,  noplot="",
     lty=c(3,3,2,2,1,1), lwd=2, xscale=12,
     xlab="Years post diagnosis", ylab="P(state)")
legend(240, .65, c("Female, death", "Male, death", "malignancy", "(s0)"),
       lty=c(1,1,2,3), col=c(1,2,1,1), bty='n', lwd=2)


###################################################
### code chunk number 15: mgus3
###################################################
getOption("SweaveHooks")[["fig"]]()
pcmbad <- survfit(Surv(etime, pstat) ~ sex, data=mgus2)
plot(pcmbad[2], mark.time=FALSE, lwd=2, fun="event", conf.int=FALSE, xscale=12,
     xlab="Years post diagnosis", ylab="Fraction with PCM")
lines(crfit[2,2], lty=2, lwd=2, mark.time=FALSE, conf.int=FALSE)
legend(0, .25, c("Males, PCM, incorrect curve", "Males, PCM, competing risk"),
       col=1, lwd=2, lty=c(1,2), bty='n')


###################################################
### code chunk number 16: survival.Rnw:840-843
###################################################
dim(crfit)
crfit$strata
crfit$states


###################################################
### code chunk number 17: overall
###################################################
myeloid[1:5,]


###################################################
### code chunk number 18: sfit0
###################################################
getOption("SweaveHooks")[["fig"]]()
sfit0 <- survfit(Surv(futime, death) ~ trt, myeloid)
plot(sfit0, xscale=365.25, xaxs='r', col=1:2, lwd=2,
     xlab="Years post enrollment", ylab="Survival")
legend(20, .4, c("Arm A", "Arm B"),
       col=1:2, lwd=2, bty='n')


###################################################
### code chunk number 19: sfit0a
###################################################
mdata <- tmerge(myeloid[,1:2], myeloid,  id=id,  death= event(futime, death),
                sct = event(txtime), cr = event(crtime), 
                relapse = event(rltime))
temp <- with(mdata, cr + 2*sct  + 4*relapse + 8*death)
table(temp)


###################################################
### code chunk number 20: sfit0b
###################################################
tdata <- myeloid  # temporary working copy
tied <- with(tdata, (!is.na(crtime) & !is.na(txtime) & crtime==txtime))
tdata$crtime[tied] <- tdata$crtime[tied] -1
mdata <- tmerge(tdata[,1:2], tdata,  id=id,  death= event(futime, death),
                sct = event(txtime), cr = event(crtime), 
                relapse = event(rltime),
                priorcr = tdc(crtime), priortx = tdc(txtime))
temp <- with(mdata, cr + 2*sct  + 4*relapse + 8*death)
table(temp)
mdata$event <- factor(temp, c(0,1,2,4,8),
                       c("none", "CR", "SCT", "relapse", "death"))

mdata[1:7, c("id", "trt", "tstart", "tstop", "event", "priorcr", "priortx")]


###################################################
### code chunk number 21: survival.Rnw:978-979
###################################################
survcheck(Surv(tstart, tstop, event) ~1, mdata, id=id)


###################################################
### code chunk number 22: newevent
###################################################
levels(mdata$event)
temp1        <- with(mdata, ifelse(priorcr, 0, c(0,1,0,0,2)[event]))
mdata$crstat <- factor(temp1, 0:2, c("none", "CR", "death"))

temp2        <- with(mdata, ifelse(priortx, 0, c(0,0,1,0,2)[event]))
mdata$txstat <- factor(temp2, 0:2, c("censor", "SCT", "death"))

temp3     <- with(mdata, c(0,0,1,0,2)[event] + priortx)
mdata$tx2 <- factor(temp3, 0:3,
                    c("censor", "SCT", "death w/o SCT", "death after SCT"))


###################################################
### code chunk number 23: curve1
###################################################
getOption("SweaveHooks")[["fig"]]()
# I want to have the plots in months, it is simpler to fix time
#  once rather than repeat xscale many times
tdata$futime <- tdata$futime * 12 /365.25
mdata$tstart <- mdata$tstart * 12 /365.25
mdata$tstop  <- mdata$tstop * 12 /365.25


sfit1 <- survfit(Surv(futime, death)  ~ trt, tdata) # survival
sfit2 <- survfit(Surv(tstart, tstop, crstat) ~ trt, 
                 data= mdata, id = id) # CR
sfit3 <- survfit(Surv(tstart, tstop, txstat) ~ trt, 
                 data= mdata, id =id) # SCT

layout(matrix(c(1,1,1,2,3,4), 3,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1.1, .1))

mlim   <- c(0, 48) # and only show the first 4 years
plot(sfit2[,"CR"], xlim=mlim, 
         lty=3, lwd=2, col=1:2, xaxt='n',
     xlab="Months post enrollment", ylab="Fraction with the endpoint")
lines(sfit1, mark.time=FALSE, xlim=mlim,
      fun='event', col=1:2, lwd=2)

lines(sfit3[,"SCT"], xlim=mlim, col=1:2, 
          lty=2, lwd=2)

xtime <- c(0, 6, 12, 24, 36, 48)
axis(1, xtime, xtime) #axis marks every year rather than 10 months
temp <- outer(c("A", "B"), c("CR", "transplant", "death"),  paste)
temp[7] <- ""
legend(25, .3, temp[c(1,2,7,3,4,7,5,6,7)], lty=c(3,3,3, 2,2,2 ,1,1,1),
       col=c(1,2,0), bty='n', lwd=2)
abline(v=2, lty=2, col=3)

# add the state space diagrams
par(mar=c(4,.1,1,1))
crisk(c("Entry", "CR", "Death"), alty=3)
crisk(c("Entry", "Tx", "Death"), alty=2)
crisk(c("Entry","Death"))
par(oldpar)
layout(1)


###################################################
### code chunk number 24: badfit
###################################################
getOption("SweaveHooks")[["fig"]]()
badfit <- survfit(Surv(tstart, tstop, event=="SCT") ~ trt, 
                       id=id, mdata, subset=(priortx==0))

layout(matrix(c(1,1,1,2,3,4), 3,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1.1, .1))
plot(badfit, fun="event", xmax=48, xaxt='n', col=1:2, lty=2, lwd=2,
     xlab="Months from enrollment", ylab="P(state)")
axis(1, xtime, xtime)
lines(sfit3[,2], xmax=48, col=1:2, lwd=2)
legend(24, .3, c("Arm A", "Arm B"), lty=1, lwd=2,
       col=1:2, bty='n', cex=1.2)

par(mar=c(4,.1,1,1))
crisk(c("Entry", "transplant"), alty=2, cex=1.2)
crisk(c("Entry","transplant", "Death"), cex=1.2)
par(oldpar)
layout(1)


###################################################
### code chunk number 25: cr2
###################################################
getOption("SweaveHooks")[["fig"]]()
cr2 <- mdata$event
cr2[cr2=="SCT"] <- "none" # ignore transplants
crsurv <- survfit(Surv(tstart, tstop, cr2) ~ trt,
                  data= mdata, id=id, influence=TRUE)

layout(matrix(c(1,1,2,3), 2,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1.1, .1))
plot(sfit2[,2], lty=3, lwd=2, col=1:2, xmax=12, 
     xlab="Months", ylab="CR")
lines(crsurv[,2], lty=1, lwd=2, col=1:2)
par(mar=c(4, .1, 1, 1))
crisk( c("Entry","CR", "Death"), alty=3)
state3(c("Entry", "CR", "Death/Relapse"))

par(oldpar)
layout(1)


###################################################
### code chunk number 26: cr2b
###################################################
print(crsurv, rmean=48, digits=2)


###################################################
### code chunk number 27: cr2c
###################################################
temp <- summary(crsurv, rmean=48)$table
delta <- round(temp[4,3] - temp[3,3], 2)


###################################################
### code chunk number 28: txsurv
###################################################
getOption("SweaveHooks")[["fig"]]()
event2 <- with(mdata, ifelse(event=="SCT" & priorcr==1, 6,
               as.numeric(event)))
event2 <- factor(event2, 1:6, c(levels(mdata$event), "SCT after CR"))
txsurv <- survfit(Surv(tstart, tstop, event2) ~ trt, mdata, id=id,
                  subset=(priortx ==0))
dim(txsurv) # number of strata by number of states
txsurv$states # Names of states

layout(matrix(c(1,1,1,2,2,0),3,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1,.1))
plot(txsurv[,c(3,6)], col=1:2, lty=c(1,1,2,2), lwd=2, xmax=48,
     xaxt='n', xlab="Months", ylab="Transplanted")
axis(1, xtime, xtime)
legend(15, .13, c("A, transplant without CR", "B, transplant without CR",
                 "A, transplant after CR", "B, transplant after CR"),
       col=1:2, lty=c(1,1,2,2), lwd=2, bty='n')
state4()  # add the state figure
par(oldpar)


###################################################
### code chunk number 29: sfit4
###################################################
getOption("SweaveHooks")[["fig"]]()
sfit4 <- survfit(Surv(tstart, tstop, event) ~ trt, mdata, id=id)
sfit4$transitions
layout(matrix(1:2,1,2), widths=2:1)
oldpar <- par(mar=c(5.1, 4.1, 1,.1))
plot(sfit4, col=rep(1:4,each=2), lwd=2, lty=1:2, xmax=48, xaxt='n',
     xlab="Months", ylab="Current state")
axis(1, xtime, xtime)
text(c(40, 40, 40, 40), c(.51, .13, .32, .01),
     c("Death", "CR", "Transplant", "Recurrence"), col=c(4,1,2,3))

par(mar=c(5.1, .1, 1, .1))
state5()
par(oldpar)


###################################################
### code chunk number 30: reprise
###################################################
crsurv <- survfit(Surv(tstart, tstop, cr2) ~ trt,
                  data= mdata, id=id, influence=TRUE)
curveA <- crsurv[1,]  # select treatment A

dim(curveA)    # P matrix for treatement A
curveA$states
dim(curveA$pstate)  # 426 time points, 5 states
dim(curveA$influence) # influence matrix for treatment A
table(myeloid$trt)


###################################################
### code chunk number 31: meantime
###################################################
t48 <- pmin(48, curveA$time)   
delta <- diff(c(t48, 48))  # width of intervals
rfun <- function(pmat, delta) colSums(pmat * delta)  #area under the curve
rmean <- rfun(curveA$pstate, delta)

# Apply the same calculation to each subject's influence slice
inf <- apply(curveA$influence, 1, rfun, delta=delta)
# inf is now a 5 state by 310 subject matrix, containing the IJ estimates
#  on the AUC or mean time.  The sum of squares is a variance.
se.rmean <- sqrt(rowSums(inf^2))
round(rbind(rmean, se.rmean), 2)

print(curveA, rmean=48, digits=2)


###################################################
### code chunk number 32: survdiff
###################################################
survdiff(Surv(time, status) ~ x, aml)


###################################################
### code chunk number 33: crisk
###################################################
crisk <- function(what, horizontal = TRUE, ...) {
    nstate <- length(what)
    connect <- matrix(0, nstate, nstate,
                      dimnames=list(what, what))
    connect[1,-1] <- 1  # an arrow from state 1 to each of the others
    if (horizontal) statefig(c(1, nstate-1),  connect, ...)
    else statefig(matrix(c(1, nstate-1), ncol=1), connect, ...)
}


###################################################
### code chunk number 34: state3
###################################################
state3 <- function(what, horizontal=TRUE, ...) {
    if (length(what) != 3) stop("Should be 3 states")
    connect <- matrix(c(0,0,0, 1,0,0, 1,1,0), 3,3,
                      dimnames=list(what, what))
    if (horizontal) statefig(1:2, connect, ...)
    else statefig(matrix(1:2, ncol=1), connect, ...)
}


###################################################
### code chunk number 35: state5
###################################################
state5 <- function(what, ...) {
    sname <- c("Entry", "CR", "Tx", "Rel", "Death")
    connect <- matrix(0, 5, 5, dimnames=list(sname, sname))
    connect[1, -1] <- c(1,1,1, 1.4)
    connect[2, 3:5] <- c(1, 1.4, 1)
    connect[3, c(2,4,5)] <- 1
    connect[4, c(3,5)]  <- 1
    statefig(matrix(c(1,3,1)), connect, cex=.8, ...)
}


###################################################
### code chunk number 36: state4
###################################################
state4 <- function() {
    sname <- c("Entry", "CR", "Transplant", "Transplant")
    layout <- cbind(x =c(1/2, 3/4, 1/4, 3/4),
                    y =c(5/6, 1/2, 1/2, 1/6))
    connect <- matrix(0,4,4, dimnames=list(sname, sname))
    connect[1, 2:3] <- 1
    connect[2,4] <- 1
    statefig(layout, connect)
}


###################################################
### code chunk number 37: lung1
###################################################
options(show.signif.stars=FALSE)  # display statistical intelligence
cfit1 <- coxph(Surv(time, status) ~ age + sex + wt.loss, data=lung)
print(cfit1, digits=3)
summary(cfit1, digits=3)
anova(cfit1)


###################################################
### code chunk number 38: na.action
###################################################
cfit1a <- coxph(Surv(time, status) ~ age + sex + wt.loss, data=lung,
                na.action = na.omit)
cfit1b <- coxph(Surv(time, status) ~ age + sex + wt.loss, data=lung,
                na.action = na.exclude)
r1 <- residuals(cfit1a)
r2 <- residuals(cfit1b)
length(r1)
length(r2)


###################################################
### code chunk number 39: cox12
###################################################
cfit2 <- coxph(Surv(time, status) ~ age + sex + wt.loss + strata(inst),
               data=lung)
round(cbind(simple= coef(cfit1), stratified=coef(cfit2)), 4)


###################################################
### code chunk number 40: cox13
###################################################
getOption("SweaveHooks")[["fig"]]()
dummy <- expand.grid(age=c(50, 60), sex=1, wt.loss=5)
dummy

csurv1 <- survfit(cfit1, newdata=dummy)
csurv2 <- survfit(cfit2, newdata=dummy)
dim(csurv1)
dim(csurv2)
plot(csurv1, col=1:2, xscale=365.25, xlab="Years", ylab="Survival")

dummy2 <- data.frame(age=c(50, 60), sex=1:2, wt.loss=5, inst=c(6,11))
csurv3 <- survfit(cfit2, newdata=dummy2)
dim(csurv3)


###################################################
### code chunk number 41: lung2
###################################################
getOption("SweaveHooks")[["fig"]]()
zp1 <- cox.zph(cfit1)
zp1
plot(zp1[2], resid=FALSE)
abline(coef(fit1)[2] ,0, lty=3)


###################################################
### code chunk number 42: lung3
###################################################
getOption("SweaveHooks")[["fig"]]()
cfit3 <- coxph(Surv(time, status) ~ pspline(age) + sex + wt.loss, lung)
print(cfit3, digits=2)
termplot(cfit3, term=1, se=TRUE)

cfit4 <- update(cfit1, . ~ . + age*sex)
anova(cfit1, cfit4)


###################################################
### code chunk number 43: cgd1
###################################################
cfit1 <- coxph(Surv(tstart, tstop, status) ~ treat + inherit + steroids +
                   age + strata(hos.cat), data=cgd)
print(cfit1, digits=2)


###################################################
### code chunk number 44: cgd1b
###################################################
cfit2 <- coxph(Surv(tstart, tstop, status) ~ treat + inherit+
                   age + strata(hos.cat), data=cgd)
print(cfit2, digits=2)


###################################################
### code chunk number 45: cgd3
###################################################
getOption("SweaveHooks")[["fig"]]()
dummy <- expand.grid(age=c(6,12), inherit='X-linked', 
                     treat=levels(cgd$treat))
dummy
csurv <- survfit(cfit2, newdata=dummy)
dim(csurv)

plot(csurv[1,], fun="event", col=1:2, lty=c(1,1,2,2), 
     xlab="Days on study", ylab="Pr( any infection )")


###################################################
### code chunk number 46: cfit4
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(csurv[1,], cumhaz=TRUE, col=1:2, lty=c(1,1,2,2), lwd=2,
     xlab="Days on study", ylab="E( number of infections )")
legend(20, 1.5, c("Age 6, control", "Age 12, control",
                "Age 6, gamma interferon", "Age 12, gamma interferon"),
       lty=c(2,2,1,1), col=c(1,2,1,2), lwd=2, bty='n')


###################################################
### code chunk number 47: survfit-mgus1
###################################################
getOption("SweaveHooks")[["fig"]]()
mgus2[56:59,]

sname <- c("MGUS", "Malignancy", "Death")
smat <- matrix(c(0,0,0, 1,0,0, 1,1,0), 3, 3, 
               dimnames = list(sname, sname))
statefig(c(1,2), smat)


###################################################
### code chunk number 48: survfit-mgus2
###################################################
crdata <- mgus2
crdata$etime <- pmin(crdata$ptime, crdata$futime)
crdata$event <- ifelse(crdata$pstat==1, 1, 2*crdata$death)
crdata$event <- factor(crdata$event, 0:2, c("censor", "PCM", "death"))

quantile(crdata$age, na.rm=TRUE)
table(crdata$sex)
quantile(crdata$mspike, na.rm=TRUE)

cfit <- coxph(Surv(etime, event) ~ I(age/10) + sex + mspike, 
              id = id, crdata)
print(cfit, digits=1)  # narrow the printout a bit


###################################################
### code chunk number 49: PCMcurve
###################################################
getOption("SweaveHooks")[["fig"]]()
dummy <- expand.grid(sex=c("F", "M"), age=c(60, 80), mspike=1.2)
csurv  <- survfit(cfit, newdata=dummy)
plot(csurv[,,2], xmax=20*12, xscale=12,
     xlab="Years after MGUS diagnosis", ylab="Pr(has entered PCM state)",
     col=1:2, lty=c(1,1,2,2), lwd=2)
legend(100, .04, outer(c("female,", "male,  "), 
                     c("diagnosis at age 60", "diagnosis at age 80"), 
                      paste),
       col=1:2, lty=c(1,1,2,2), bty='n', lwd=2)


###################################################
### code chunk number 50: mrate
###################################################
mpfit <- glm(pstat ~ sex -1 + offset(log(ptime)), data=mgus2, poisson)
exp(coef(mpfit)) * 12   # rate per year


###################################################
### code chunk number 51: msingle
###################################################
getOption("SweaveHooks")[["fig"]]()
sfit <- coxph(Surv(etime, event=="PCM") ~ I(age/10) + sex + mspike, crdata)
rbind(single = coef(sfit),
      multi  = coef(cfit)[1:3])
#par(mfrow=c(1,2))
ssurv <- survfit(sfit, newdata=dummy)
plot(ssurv[3:4], col=1:2, lty=2, xscale=12, xmax=12*20, lwd=2, fun="event",
     xlab="Years from diagnosis", ylab= "Pr(has entered PCM state)")
lines(csurv[3:4, 2], col=1:2, lty=1, lwd=2)
legend(20, .22, outer(c("80 year old male,", "80 year old female,"),
                      c("incorrect", "correct"), paste),
                  col=1:2, lty=c(2,2,1,1), lwd=2, bty='n')


###################################################
### code chunk number 52: state5
###################################################
getOption("SweaveHooks")[["fig"]]()
state5 <- c("0MC", "1MC", "2MC", "3MC", "death")
tmat <- matrix(0L, 5, 5, dimnames=list(state5, state5))
tmat[1,2] <- tmat[2,3] <- tmat[3,4] <- 1
tmat[-5,5] <- 1
statefig(rbind(4,1), tmat)


###################################################
### code chunk number 53: nafld1
###################################################
ndata <- tmerge(nafld1[,1:8], nafld1, id=id, death= event(futime, status))
ndata <- tmerge(ndata, subset(nafld3, event=="nafld"), id, 
                nafld= tdc(days))
ndata <- tmerge(ndata, subset(nafld3, event=="diabetes"), id = id,
                diabetes = tdc(days), e1= event(days))
ndata <- tmerge(ndata, subset(nafld3, event=="htn"),  id = id,
                htn = tdc(days), e2 = event(days))
ndata <- tmerge(ndata, subset(nafld3, event=="dyslipidemia"), id=id,
                lipid = tdc(days), e3= event(days))
attr(ndata, "tcount")


###################################################
### code chunk number 54: survival.Rnw:2035-2038
###################################################
tc <- attr(ndata, 'tcount')   # shorter name for use in Sexpr below
icount <- table(table(nafld3$id)) #number with 1, 2, ... intervals
ncount <- sum(nafld3$event=="nafld")


###################################################
### code chunk number 55: nafld2
###################################################
ndata$cstate <- with(ndata, diabetes + htn + lipid)
temp <- with(ndata, e1 + e2 + e3)
temp2 <- with(ndata, ifelse(death, 4, 
              ifelse(temp ==0, 0, cstate + temp)))
ndata$event <- factor(temp2, 0:4, 
         c("censored", "1mc", "2mc", "3mc", "death"))
ndata$cstate <- factor(ndata$cstate, 0:3,
                       c("0mc", "1mc", "2mc", "3mc"))
ndata$age1 <- ndata$age + ndata$tstart/365.25   # analysis on age scale
ndata$age2 <- ndata$age + ndata$tstop/365.25

temp3 <- survcheck(Surv(age1, age2, event) ~ nafld, data=ndata, 
                   id=id, istate=cstate)
temp3


###################################################
### code chunk number 56: nafld3
###################################################



###################################################
### code chunk number 57: nafld4
###################################################
nfit1 <- coxph(list(Surv(age1, age2, event) ~ nafld + male,
                    "0mc":state("1mc", "2mc", "3mc") ~ nafld+ male / common,
                     2:3 + 2:4   ~ nafld + male / common,
                     0: "death" ~ male / common),
               data=ndata, id=id, istate=cstate)
nfit1$states
round(coef(nfit1), 3)
nfit1$cmap


###################################################
### code chunk number 58: nafld5
###################################################
options(show.signif.stars = FALSE) # display statistical maturity
print(summary(nfit1, digits =3))

print(nfit1, digits =3)


###################################################
### code chunk number 59: survival.Rnw:2210-2212 (eval = FALSE)
###################################################
## fit2 <- coxph(Surv(time, status) ~ trt + trt*time + celltype + karno,
##                 data = veteran)


###################################################
### code chunk number 60: zphcheck1
###################################################
dtime <- unique(veteran$time[veteran$status==1]) # unique times
newdata <- survSplit(Surv(time, status) ~ trt + celltype + karno,
                     data=veteran, cut=dtime)
nrow(veteran)
nrow(newdata)
fit0 <- coxph(Surv(time, status) ~ trt + celltype + karno, veteran)
fit1 <- coxph(Surv(tstart, time, status) ~ trt + celltype + karno, 
              data=newdata)
fit2 <- coxph(Surv(tstart, time, status) ~ trt + celltype + karno +
              time:karno, newdata)
fit2

fit2b <- coxph(Surv(tstart, time, status) ~ trt + celltype + karno +
              rank(time):karno, newdata)


###################################################
### code chunk number 61: zph2
###################################################
fit2 <- coxph(Surv(tstart, time, status) ~ trt + celltype + karno +
              tt(karno), data =newdata,
              tt = function(x, t,...) x*t)


###################################################
### code chunk number 62: zph2
###################################################
getOption("SweaveHooks")[["fig"]]()
zp0 <- cox.zph(fit0, transform='identity')
zp0
zp1 <- cox.zph(fit0, transform='log')
zp1
oldpar <- par(mfrow=c(2,2))
for (i in 1:3) {plot(zp1[i]); abline(0,0, lty=3)}
plot(zp0[3])
par(oldpar)


###################################################
### code chunk number 63: survival.Rnw:2398-2399
###################################################
with(subset(aml, x=="Nonmaintained"), Surv(time, status))


###################################################
### code chunk number 64: coarsen
###################################################
getOption("SweaveHooks")[["fig"]]()
tdata <- subset(colon, etype==1)   # progression or death
cmat <- matrix(0, 7, 6)
for( i in 1:7) {
    if (i==1) scale <-1 else scale <- (i-1)*365/12
    temp <- floor(tdata$time/scale)
    tfit <-  coxph(Surv(temp, status) ~ node4 + extent, tdata)
    tfit2 <- coxph(Surv(temp, status) ~ node4 + extent, tdata,
                   ties='breslow')
    tfit3 <- coxph(Surv(temp, status) ~ node4 + extent, tdata,
                   ties='exact')
    cmat[i,] <- c(coef(tfit2), coef(tfit), coef(tfit3))
}
matplot(1:7, cmat[,c(1,3,5)], xaxt='n', pch='bec',
        xlab="Time divisor", ylab="Coefficient for node4")
axis(1, 1:7, c(1, floor(1:6 *365/12)))


